clear all
clc

% Creating the main UI figure
mainFig = uifigure("Name", "Brachytherapy Infrastructure Shielding Calculations");
mainFig.Resize = 'off'; % Disable resizing
mainFig.WindowState = 'normal'; % Ensure the window is in normal state
set(mainFig, 'Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);

% Creating tab group and tabs
tabGroup = uitabgroup(mainFig, 'Units', 'normalized', "Position", [0, 0, 1, 1]);
shieldingTab = uitab(tabGroup, "Title", "Shielding Thickness");
shieldingTab.Scrollable = "on";

% Source data
sourceData = struct();
sourceData.Ir192.RAKR = 0.111;
sourceData.Ir192.TVLe = struct('Lead', 16, 'Steel', 43, 'Concrete', 152);
sourceData.Ir192.TVL1 = struct('Lead', [], 'Steel', 49, 'Concrete', []);

sourceData.Co60.RAKR = 0.308;
sourceData.Co60.TVLe = struct('Lead', 41, 'Steel', 71, 'Concrete', 218);
sourceData.Co60.TVL1 = struct('Lead', [], 'Steel', 87, 'Concrete', 245);

sourceData.I125.RAKR = 0.034;
sourceData.I125.TVLe = struct('Lead', 0.1, 'Steel', [], 'Concrete', []);
sourceData.I125.TVL1 = struct('Lead', [], 'Steel', [], 'Concrete', []);

sourceData.Cs137.RAKR = 0.077;
sourceData.Cs137.TVLe = struct('Lead', 22, 'Steel', 53, 'Concrete', 175);
sourceData.Cs137.TVL1 = struct('Lead', [], 'Steel', 69, 'Concrete', []);

sourceData.Au198.RAKR = 0.056;
sourceData.Au198.TVLe = struct('Lead', 11, 'Steel', [], 'Concrete', 142);
sourceData.Au198.TVL1 = struct('Lead', [], 'Steel', [], 'Concrete', []);

sourceData.Ra226.RAKR = 0.195;
sourceData.Ra226.TVLe = struct('Lead', 45, 'Steel', 76, 'Concrete', 240);
sourceData.Ra226.TVL1 = struct('Lead', [], 'Steel', 86, 'Concrete', []);

%Densities
density = struct();
density.Concrete = 2.5e-6;
density.Steel = 7.8e-6;
density.Lead = 1.11e-5;

% Dropdown for sources
sourceLabel = uilabel(shieldingTab, 'Text', 'Source', 'Position', [20, 550, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown = uidropdown(shieldingTab, "Items", fieldnames(sourceData), 'Position', [120, 550, 130, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown.ValueChangedFcn = @(dd, event) updateSourceData(dd, sourceData);

% Labels and Edit Fields for workload calculations
activityLabel = uilabel(shieldingTab, 'Text', 'Activity [MBq]', 'Position', [20, 525, 80, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
durationLabel = uilabel(shieldingTab, 'Text', 'Duration [hours]', 'Position', [20, 475, 80, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsLabel = uilabel(shieldingTab, 'Text', 'Treatments [per week]', 'Position', [20, 450, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
numberSourcesLabel = uilabel(shieldingTab, 'Text', 'Sources', 'Position', [20, 500, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

activityEditField = uieditfield(shieldingTab, 'numeric', 'Position', [130, 525, 50, 22], "ValueDisplayFormat", "%.2f");
durationEditField = uieditfield(shieldingTab, 'numeric', 'Position', [130, 475, 50, 22], "ValueDisplayFormat", "%.2f");
treatmentsEditField = uieditfield(shieldingTab, 'numeric', 'Position', [130, 450, 50, 22], "ValueDisplayFormat", "%.2f");
numberSourcesEditField = uieditfield(shieldingTab,'numeric', 'Position',[130, 500, 50, 22], "ValueDisplayFormat", "%.2f");

% Labels and Edit Fields for Transmission Factor Calculations
designLimitLabel = cell(1,6);
designLimitAreaDropdown = cell(1,6);
distanceLabel = cell(1,6);
occupationFactorLabel = cell(1,6);
designLimitEditField = cell(1,6);
distanceEditField = cell(1,6);
occupationFactorEditField = cell(1,6);
for i = 1:6
    designLimitLabel{i} = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [360, 525-(i-1)*25, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    designLimitAreaDropdown{i} = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [460, 525-(i-1)*25, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    distanceLabel{i} = uilabel(shieldingTab, 'Text', ['Distance' num2str(i) ' [m]'], 'Position', [200, 525-(i-1)*25, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    occupationFactorLabel{i} = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [620, 525-(i-1)*25, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    designLimitEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [540, 525-(i-1)*25, 50, 22], "ValueDisplayFormat", "%.2f", 'Editable', 'off');
    distanceEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [280, 525-(i-1)*25, 50, 22], "ValueDisplayFormat", "%.2f");
    occupationFactorEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [715, 525-(i-1)*25, 50, 22], "ValueDisplayFormat", "%.2f");

    % Callback to designLimitAreaDropdown to update designLimitEditField
    designLimitAreaDropdown{i}.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimitEditField{i});
end

workloadLabel = uilabel(shieldingTab, 'Text', 'Workload [μGym^2/week]', 'Position', [20, 375, 175, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
workloadValue = uilabel(shieldingTab, 'Text', '-', 'Position', [200, 375, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels and Edit Fields for Material Prices
ConcretePriceLabel = uilabel(shieldingTab, "Text", "Concrete Price [Eu/Kg]", "Position", [795, 525, 110, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
SteelPriceLabel = uilabel(shieldingTab, "Text", "Steel Price [Eu/Kg]", "Position", [795, 500, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
LeadPriceLabel = uilabel(shieldingTab, "Text", "Lead Price [Eu/Kg]", "Position", [795, 475, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

PriceEditField = struct();
PriceEditField.Concrete = uieditfield(shieldingTab, 'numeric', 'Position', [910, 525, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Steel = uieditfield(shieldingTab, 'numeric', 'Position', [910, 500, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Lead = uieditfield(shieldingTab, 'numeric', 'Position', [910, 475, 50, 22], "ValueDisplayFormat", "%.2f");

tableData = cell(3, 12);  % Cell array for the table data

% Column headers for the table
columnNames = cell(1,12);
for i = 1:6
    columnNames{2*i-1} = ['Thickness' num2str(i)];
    columnNames{2*i} = ['Cost' num2str(i)];
end
% Create the table in the UI (positioned at the bottom for displaying results)
resultTable = uitable(shieldingTab, 'Data', tableData, ...
    'ColumnName', columnNames, ...
    'Position', [20, 200, 1018, 98.70], ... % Adjust position and size as needed
    'ColumnWidth', repmat({80}, 1, 12), ... % Set uniform column widths
    'RowName', {'Lead', 'Steel', 'Concrete'});  % Row names for materials

% Calculating shielding thickness and updating the table
calcButton = uibutton(shieldingTab, 'Position', [810, 450, 100, 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, numberSourcesEditField, sourceData, density, PriceEditField, resultTable, tableData);

% Function to update designLimitEditField based on dropdown selection
function setDesignLimit(dd, designLimitEditField)
switch dd.Value
    case "Controlled Area"
        designLimitEditField.Value = 200;
    case "Uncontrolled Area"
        designLimitEditField.Value = 60;
    case "Public Area"
        designLimitEditField.Value = 6;
    otherwise
        designLimitEditField.Value = 0; % Default or clear value
end
end

% Update source data based on selected source
function updateSourceData(sourceDropdown, sourceData)
selectedSource = sourceData.(sourceDropdown.Value);
end

% Function to calculate shielding thickness and update the table
function calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, numberSourcesEditField, sourceData, density, PriceEditField, resultTable, tableData)
% Get the selected source data
selectedSource = sourceData.(sourceDropdown.Value);

% Calculate the workload
workload = selectedSource.RAKR * activityEditField.Value * numberSourcesEditField.Value * durationEditField.Value * treatmentsEditField.Value;
workloadValue.Text = sprintf('%.2f', workload);

% Pre-allocate arrays to store thickness and cost results
transmissionFactor = zeros(1,6);
attenuationFactor = zeros(1,6);
thickness = zeros(3,6);  % 3 materials (Lead, Steel, Concrete), 6 distances
cost = zeros(3,6);       % Same size for cost

% Loop through the 6 distances and calculate thickness and cost
for i = 1:6
    transmissionFactor(i) = (designLimitEditField{i}.Value * distanceEditField{i}.Value^2) / (workload * occupationFactorEditField{i}.Value);
    attenuationFactor(i) = log10(1 / transmissionFactor(i));

    % For each material, calculate thickness and cost
    materials = fieldnames(selectedSource.TVLe);  % Lead, Steel, Concrete
    for j = 1:length(materials)
        material = materials{j};
        TVLe = selectedSource.TVLe.(material);
        TVL1 = selectedSource.TVL1.(material);

        if isempty(TVL1)
            TVL1 = 0;  % Set TVL1 to zero if not provided
        end

        % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
        thickness(j,i) = TVL1 + (attenuationFactor(i)-1)*TVLe;


        % Calculate cost based on material density and price per kg
        % Assuming thickness is in mm, convert to meters for volume calculation
        thickness_m = thickness(j,i);  % Convert mm to meters
        volume = thickness_m^3;  % Volume in m^3
        mass = density.(material) * volume;  % Mass in kg (assuming density units are consistent)
        cost(j,i) = PriceEditField.(material).Value * mass;

        % Update the table data for the current material and distance
        tableData{j,2*i-1} = sprintf('%.2f mm', thickness(j,i));  % Thickness in mm
        tableData{j, 2*i} = sprintf('€ %.2f', cost(j,i));        % Cost in EUR

    end
end

% Update the UITable with the new data
resultTable.Data = tableData;
end
