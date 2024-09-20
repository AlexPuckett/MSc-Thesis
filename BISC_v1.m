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

% Dropdown for sources
sourceLabel = uilabel(shieldingTab, 'Text', 'Source', 'Position', [20, 550, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown = uidropdown(shieldingTab, "Items", fieldnames(sourceData), 'Position', [120, 550, 130, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown.ValueChangedFcn = @(dd, event) updateSourceData(dd, sourceData);

% Labels and Edit Fields for workload calculations
activityLabel = uilabel(shieldingTab, 'Text', 'Activity [MBq]', 'Position', [20, 525, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
durationLabel = uilabel(shieldingTab, 'Text', 'Duration [hours]', 'Position', [20, 475, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsLabel = uilabel(shieldingTab, 'Text', 'Treatments [per week]', 'Position', [20, 450, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
numberSourcesLabel = uilabel(shieldingTab, 'Text', 'Sources', 'Position', [20, 500, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

activityEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 525, 50, 22], "ValueDisplayFormat", "%.2f");
durationEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 475, 50, 22], "ValueDisplayFormat", "%.2f");
treatmentsEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 450, 50, 22], "ValueDisplayFormat", "%.2f");
numberSourcesEditField = uieditfield(shieldingTab,'numeric', 'Position',[140, 500, 50, 22], "ValueDisplayFormat", "%.2f");

% Labels and Edit Fields for transmition factor calculations
designLimitLabel = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [20, 425, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimitAreaDropdown = uidropdown(shieldingTab, "Items", ["Select Area", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [200, 425, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distanceLabel = uilabel(shieldingTab, 'Text', 'Distance [m]', 'Position', [20, 400, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
occupationFactorLabel = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [20, 375, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
workloadLabel = uilabel(shieldingTab, 'Text', 'Workload [μGym^2/week]', 'Position', [20, 250, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
transmissionFactorLabel = uilabel(shieldingTab, 'Text', 'Transmission Factor', 'Position', [20, 225, 140, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

designLimitEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 425, 50, 22], "ValueDisplayFormat", "%.2f");
distanceEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 400, 50, 22], "ValueDisplayFormat", "%.2f");
occupationFactorEditField = uieditfield(shieldingTab, 'numeric', 'Position', [140, 375, 50, 22], "ValueDisplayFormat", "%.2f");
workloadValue = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 250, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
transmissionFactorValue = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 225, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels and Edit Fields for Material Prices
ConcretePriceLabel = uilabel(shieldingTab, "Text", "Concrete Price [Eu/Kg]", "Position", [20, 350, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
SteelPriceLabel = uilabel(shieldingTab, "Text", "Steel Price [Eu/Kg]", "Position", [20, 325, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
LeadPriceLabel = uilabel(shieldingTab, "Text", "Lead Price [Eu/Kg]", "Position", [20, 300, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

PriceEditField = struct();
PriceEditField.Concrete = uieditfield(shieldingTab, 'numeric', 'Position', [140, 350, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Steel = uieditfield(shieldingTab, 'numeric', 'Position', [140, 325, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Lead = uieditfield(shieldingTab, 'numeric', 'Position', [140, 300, 50, 22], "ValueDisplayFormat", "%.2f");

%Densities
density = struct();
density.Concrete = 2.5e-6;
density.Steel = 7.8e-6;
density.Lead = 1.11e-5;

% Labels and fields to display calculated thickness
thicknessLabels = struct();
thicknessLabels.Lead = uilabel(shieldingTab, 'Text', 'Lead Thickness [mm]:', 'Position', [20, 200, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Steel = uilabel(shieldingTab, 'Text', 'Steel Thickness [mm]:', 'Position', [20, 175, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Concrete = uilabel(shieldingTab, 'Text', 'Concrete Thickness [mm]:', 'Position', [20, 150, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels to display calculated values
thicknessValues = struct();
thicknessValues.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 200, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 175, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 150, 500, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

priceValues = struct();
priceValues.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [230, 200, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [230, 175, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [230, 150, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Button for calculation
calcButton = uibutton(shieldingTab, 'Position', [20 275 140 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorValue, thicknessValues, priceValues, numberSourcesEditField, sourceData, density, PriceEditField);

% Assigning callbacks for dropdowns
designLimitAreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimitEditField);

function setDesignLimit(areaDropdown, designLimitEditField)
    switch areaDropdown.Value
        case "Controlled Area"
            designLimitEditField.Value = 200;
        case "Uncontrolled Area"
            designLimitEditField.Value = 60;
        case "Public Area"
            designLimitEditField.Value = 6;
    end
end

% Update source data based on selected source
function updateSourceData(sourceDropdown, sourceData)
    selectedSource = sourceData.(sourceDropdown.Value);
end

% Callback function for shielding thickness calculation
function calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorValue, thicknessValues, priceValues, numberSourcesEditField, sourceData, density, PriceEditField)
    selectedSource = sourceData.(sourceDropdown.Value);
    workload = selectedSource.RAKR * activityEditField.Value * numberSourcesEditField.Value * durationEditField.Value * treatmentsEditField.Value;
    workloadValue.Text = sprintf('%.2f', workload);
    transmissionFactor = (designLimitEditField.Value * distanceEditField.Value^2) / (workload * occupationFactorEditField.Value);
    transmissionFactorValue.Text = sprintf('%.2e', transmissionFactor);

    % Calculate the attenuation factor
    attenuationFactor = log10(1 / transmissionFactor);

    % Calculate and display thickness for each material
    materials = fieldnames(selectedSource.TVLe);
    for i = 1:length(materials)
        material = materials{i};
        TVLe = selectedSource.TVLe.(material);
        TVL1 = selectedSource.TVL1.(material);

        if isempty(TVL1)
            TVL1 = 0; % Set TVL1 to zero if not provided
        end
        
        % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
        thickness = TVL1 + (attenuationFactor - 1) * TVLe;
        thicknessValues.(material).Text = sprintf('%.2f', thickness);
        price = PriceEditField.(material).Value * density.(material) * thickness^3;
        priceValues.(material).Text = sprintf('%.2f Eu', price);
    end
end