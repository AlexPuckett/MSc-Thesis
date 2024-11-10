clearvars
clc

% Creating the main UI figure
mainFig = uifigure("Name", "Brachytherapy Infrastructure Shielding Calculations");
mainFig.Resize = 'off'; % Disable resizing
mainFig.WindowState = 'normal'; % Ensure the window is in normal state
set(mainFig, 'Units', 'normalized', 'Position', [0.05, 0.05, 0.9, 0.9]);

% Creating tab group and tabs
tabGroup = uitabgroup(mainFig, 'Units', 'normalized', "Position", [0, 0, 1, 1]);
shieldingTab = uitab(tabGroup, "Title", "Shielding Thickness");
shieldingTab.Scrollable = "on";

% Source data
sourceData = struct();
sourceData.Ir192.RAKR = 0.111; %uGym^2/MBqh
sourceData.Ir192.E = 0.37; %MeV gamma ray
sourceData.Ir192.Lead = 28330; %mass coefficient mm2/kg through interpolation with values from NIST XCOM
sourceData.Ir192.Steel = 98770;
sourceData.Ir192.Concrete = 12108;
sourceData.Ir192.F = 0.93; % Tissue Air ratio F(D,theta) for path length of 10cm in water Safety Report Series No.47
sourceData.Ir192.TVLe = struct('Lead', 16, 'Steel', 43, 'Concrete', 152);
sourceData.Ir192.TVL1 = struct('Lead', [], 'Steel', 49, 'Concrete', []);

sourceData.Co60.RAKR = 0.308;
sourceData.Co60.E = 1.25;
sourceData.Co60.Lead = 5876;
sourceData.Co60.Steel = 5350;
sourceData.Co60.Concrete = 5404;
sourceData.Co60.F = 0.81;
sourceData.Co60.TVLe = struct('Lead', 41, 'Steel', 71, 'Concrete', 218);
sourceData.Co60.TVL1 = struct('Lead', [], 'Steel', 87, 'Concrete', 245);

sourceData.Cs137.RAKR = 0.077;
sourceData.Cs137.E = 0.662;
sourceData.Cs137.Lead = 11400;
sourceData.Cs137.Steel = 7390;
sourceData.Cs137.Concrete = 7844;
sourceData.Cs137.F = 0.86;
sourceData.Cs137.TVLe = struct('Lead', 22, 'Steel', 53, 'Concrete', 175);
sourceData.Cs137.TVL1 = struct('Lead', [], 'Steel', 69, 'Concrete', []);

sourceData.Au198.RAKR = 0.056;
sourceData.Au198.E = 0.42;
sourceData.Au198.Lead = 21812;
sourceData.Au198.Steel = 9203;
sourceData.Au198.Concrete = 10694;
sourceData.Au198.F = 0.90;
sourceData.Au198.TVLe = struct('Lead', 11, 'Steel', [], 'Concrete', 142);
sourceData.Au198.TVL1 = struct('Lead', [], 'Steel', [], 'Concrete', []);

sourceData.Ra226.RAKR = 0.195;
sourceData.Ra226.E = 0.78;
sourceData.Ra226.Lead = 9231;
sourceData.Ra226.Steel = 7061.4;
sourceData.Ra226.Concrete = 7067;
sourceData.Ra226.F = 0.86;
sourceData.Ra226.TVLe = struct('Lead', 45, 'Steel', 76, 'Concrete', 240);
sourceData.Ra226.TVL1 = struct('Lead', [], 'Steel', 86, 'Concrete', []);

%Densities kg/mm3
density = struct();
density.Concrete = 4.2e-6;
density.Steel = 7.9e-6;
density.Lead = 1.13e-5;

% Dropdown for sources
sourceLabel = uilabel(shieldingTab, 'Text', 'S', 'Interpreter', 'tex', 'Position', [20, 640, 10, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown = uidropdown(shieldingTab, "Items", fieldnames(sourceData), 'Position', [85, 640, 65, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown.ValueChangedFcn = @(dd, event) updateSourceData(dd, sourceData);

%Chechbox to add patient attenuation or not
cbx = uicheckbox(shieldingTab,"Text","Pt.Att.", 'Position',[160,640,70,22]);
cbx_idr = uicheckbox(shieldingTab,"Text","IDR", 'Position',[225,640,70,22]);
cbx_nomaze = uicheckbox(shieldingTab,"Text","NoMaze", 'Position',[280,640,70,22]);
cbx_onelegmaze = uicheckbox(shieldingTab,"Text","OneLeg", 'Position',[350,640,70,22]);
cbx_twolegmaze = uicheckbox(shieldingTab,"Text","TwoLeg", 'Position',[430,640,70,22]);

% Labels and Edit Fields for workload calculations
activityLabel = uilabel(shieldingTab, 'Text', 'A[MBq]', 'Position', [20, 615, 75, 22], 'Interpreter', 'tex', 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
doseLabel = uilabel(shieldingTab, 'Text', 'D[Gy/pt]', 'Position', [20, 565, 75, 22], 'Interpreter', 'tex', 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
rateLabel = uilabel(shieldingTab, 'Text', 'D_{rate}[Gy/min]', 'Interpreter', 'tex', 'Position', [20, 540, 75, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsLabel = uilabel(shieldingTab, 'Text', 'Tr_{per week}', 'Interpreter', 'tex', 'Position', [20, 515, 75, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsidrLabel = uilabel(shieldingTab, 'Text', 'Tr_{per day}', 'Interpreter', 'tex', 'Position', [20, 490, 75, 22,], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
numberSourcesLabel = uilabel(shieldingTab, 'Text', '#S', 'Interpreter', 'tex', 'Position', [20, 590, 75, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

activityEditField = uieditfield(shieldingTab, 'numeric', 'Position', [85, 615, 48, 22], "ValueDisplayFormat", "%.2f");
doseEditField = uieditfield(shieldingTab, 'numeric', 'Position', [85, 565, 48, 22], "ValueDisplayFormat", "%.2f");
rateEditField = uieditfield(shieldingTab, 'numeric', 'Position', [85, 540, 48, 22], "ValueDisplayFormat", "%.2f");
treatmentsEditField = uieditfield(shieldingTab, 'numeric', 'Position', [85, 515, 48, 22], "ValueDisplayFormat", "%.2f", 'Editable', 'off');
treatmentsidrEditField = uieditfield(shieldingTab, 'numeric', 'Position', [85, 490, 48, 22], "ValueDisplayFormat", "%.2f", 'Editable', 'off');
numberSourcesEditField = uieditfield(shieldingTab,'numeric', 'Position',[85, 590, 48, 22], "ValueDisplayFormat", "%.2f");

% Labels and Edit Fields for Transmission Factor Calculations
designLimitLabel = cell(1,6);
designLimitAreaDropdown = cell(1,6);
distanceLabel = cell(1,6);
occupationFactorLabel = cell(1,6);
areaLabel = cell(1,6);
designLimitEditField = cell(1,6);
distanceEditField = cell(1,6);
occupationFactorEditField = cell(1,6);
areaEditField = cell(1,6);
cbx_contamination = cell(1,6);
for i = 1:6
    designLimitLabel{i} = uilabel(shieldingTab, 'Text', 'P[μGy]', 'Interpreter', 'tex', 'Position', [365, 615-(i-1)*25, 40, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    designLimitAreaDropdown{i} = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [405, 615-(i-1)*25, 65, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    distanceLabel{i} = uilabel(shieldingTab, 'Text', ['d_{' num2str(i) '}[m]'], 'Interpreter', 'tex', 'Position', [150, 615-(i-1)*25, 35, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    occupationFactorLabel{i} = uilabel(shieldingTab, 'Text', 'T', 'Interpreter', 'tex', 'Position', [570, 615-(i-1)*25, 30, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    areaLabel{i} = uilabel(shieldingTab, 'Text', ['A_{' num2str(i) '}[m^{2}]'], 'Interpreter', 'tex', 'Position', [250, 615-(i-1)*25, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    designLimitEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [475, 615-(i-1)*25, 48, 22], "ValueDisplayFormat", "%.2f", 'Editable', 'off');
    distanceEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [185, 615-(i-1)*25, 48, 22], "ValueDisplayFormat", "%.2f");
    occupationFactorEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [580, 615-(i-1)*25, 48, 22], "ValueDisplayFormat", "%.2f");
    areaEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [295, 615-(i-1)*25, 48, 22], "ValueDisplayFormat", "%.2f");
    cbx_contamination{i} = uicheckbox(shieldingTab,"Text","F",'Position',[525, 615-(i-1)*25, 30, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

    % Callback to designLimitAreaDropdown to update designLimitEditField
    designLimitAreaDropdown{i}.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimitEditField{i}, cbx_idr);

    %Callback to change the design limit if contamination factor is toggled
    cbx_contamination{i}.ValueChangedFcn = @(cbx, event) updateDesignLimitWithContamination(cbx, designLimitAreaDropdown{i}, designLimitEditField{i}, cbx_idr);
end

mazedistEditField = cell(1,3);
for i = 1:3
    mazedistLabel = uilabel(shieldingTab, 'Text', ['d_{m' num2str(i) '}[m]'], 'Interpreter', 'tex', 'Position', [855, 615-(i-1)*25, 60, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    mazedistEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [905, 615-(i-1)*25, 48, 22], "ValueDisplayFormat", "%.2f");
end

mazeareaaEditField = cell(1,2);
mazeareabEditField = cell(1,2);
incidentangleEditField = cell(1,2);
refangleEditField = cell(1,2);
for i = 1:2
    mazeareaaLabel = uilabel(shieldingTab, 'Text', ['A_{m' num2str(i) 'a}[m^{2}]'], 'Interpreter', 'tex', 'Position', [640, 615-(i-1)*50, 60, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    mazeareabLabel = uilabel(shieldingTab, 'Text', ['A_{m' num2str(i) 'b}[m^{2}]'], 'Interpreter', 'tex', 'Position', [640, 590-(i-1)*50, 60, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    incidentangleLabel = uilabel(shieldingTab, 'Text', ['θ°_o' num2str(i)], 'Interpreter', 'tex', 'Position', [760, 615-(i-1)*50, 30, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    refangleLabel = uilabel(shieldingTab, 'Text', ['θ°_r' num2str(i)], 'Interpreter', 'tex', 'Position', [760, 590-(i-1)*50, 30, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
    mazeareaaEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [700, 615-(i-1)*50, 48, 22], "ValueDisplayFormat", "%.2f");
    mazeareabEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [700, 590-(i-1)*50, 48, 22], "ValueDisplayFormat", "%.2f");
    incidentangleEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [790, 615-(i-1)*50, 48, 22], "ValueDisplayFormat", "%.2f");
    refangleEditField{i} = uieditfield(shieldingTab, 'numeric', 'Position', [790, 590-(i-1)*50, 48, 22], "ValueDisplayFormat", "%.2f");
end

workloadLabel = uilabel(shieldingTab, 'Text', 'W', 'Interpreter', 'tex', 'Position', [20, 465, 175, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
workloadValue = uilabel(shieldingTab, 'Text', '-', 'Position', [80, 465, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels and Edit Fields for Material Prices
LeadPriceLabel = uilabel(shieldingTab, "Text", "Pb Pr.[Eu/Kg]", 'Interpreter', 'tex', "Position", [1005, 615, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
SteelPriceLabel = uilabel(shieldingTab, "Text", "Stl Pr.[Eu/Kg]", 'Interpreter', 'tex', "Position", [1005, 590, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
ConcretePriceLabel = uilabel(shieldingTab, "Text", "ConcBa Pr.[Eu/Kg]", 'Interpreter', 'tex', "Position", [1005, 565, 110, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

PriceEditField = struct();
PriceEditField.Lead = uieditfield(shieldingTab, 'numeric', 'Position', [1100, 615, 48, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Steel = uieditfield(shieldingTab, 'numeric', 'Position', [1100, 590, 48, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Concrete = uieditfield(shieldingTab, 'numeric', 'Position', [1100, 565, 48, 22], "ValueDisplayFormat", "%.2f");

tableData = cell(3, 13);  % Cell array for the table data

% Column headers for the result table
columnNames = cell(1,13);
columnNames{1} = 'Materials';
for i = 1:6
    columnNames{2*i} = ['Thickness' num2str(i)];
    columnNames{2*i+1} = ['Cost' num2str(i)];
end

% Create the table in the UI (positioned at the bottom for displaying results)
resultTable = uitable(shieldingTab, 'Data', tableData, 'ColumnName', columnNames, 'Position', [15, 200, 1030, 98.5], 'ColumnWidth', repmat({76}, 1, 12));

shieldData = cell(4,7); % Cell array for the shielding data

%Column headers for shielding table
columnNames1 = cell(1,7);
columnNames1{1} = 'Shielding';
for i = 1:6
    columnNames1{i+1} = ['Distance' num2str(i)];
end
shieldTable = uitable(shieldingTab, 'Data', shieldData, 'ColumnName', columnNames1, 'Position', [200, 50, 700, 122], 'ColumnWidth', repmat({95}, 1, 6));

% Adding the Save button for exporting table data to an Excel file
saveButton = uibutton(shieldingTab, 'Position', [1030, 540, 100, 22], 'Text', 'Save to Excel');
saveButton.ButtonPushedFcn = @(btn, event) saveToExcel(resultTable, shieldTable, mainFig);

% Calculating shielding thickness and updating the table
calcButton = uibutton(shieldingTab, 'Position', [1030, 515, 100, 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, doseEditField, rateEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, areaEditField, numberSourcesEditField, sourceData, density, PriceEditField, resultTable, tableData, shieldTable, shieldData, mainFig, cbx, cbx_idr);

% Callback for cbx_idr checkbox to update design limits and toggle treatment fields
cbx_idr.ValueChangedFcn = @(src, event) handleIDRToggle(src, designLimitAreaDropdown, designLimitEditField, treatmentsEditField, treatmentsidrEditField, occupationFactorEditField);

% Function to toggle the editable state of treatment fields and the design Limit values
function handleIDRToggle(cbx_idr, designLimitAreaDropdown, designLimitEditField, treatmentsEditField, treatmentsidrEditField, occupationFactorEditField)
    % Update all design limit fields
    for i = 1:length(designLimitAreaDropdown)
        % Call setDesignLimit for each dropdown and edit field pair
        setDesignLimit(designLimitAreaDropdown{i}, designLimitEditField{i}, cbx_idr);
        if cbx_idr.Value % Checkbox is selected
            treatmentsEditField.Editable = 'off';
            treatmentsidrEditField.Editable = 'on';
            occupationFactorEditField{i}.Editable = 'off';
        else % Checkbox is not selected
            treatmentsEditField.Editable = 'on';
            treatmentsidrEditField.Editable = 'off';
            occupationFactorEditField{i}.Editable = 'on';
        end
    end
end

% Function to update designLimitEditField based on dropdown selection
function setDesignLimit(dd, designLimitEditField, cbx_idr)
if cbx_idr.Value
    switch dd.Value
        case "Controlled Area"
            designLimitEditField.Value = 25 * (3/10);
        case "Uncontrolled Area"
            designLimitEditField.Value = 7.5 * (3/10);
        case "Public Area"
            designLimitEditField.Value = 2 * (3/10);
        otherwise
            designLimitEditField.Value = 0; % Default or clear value
    end
else
    % If IDR checkbox is not checked
    switch dd.Value
        case "Controlled Area"
            designLimitEditField.Value = 400 * (3/10); % uGy/week
        case "Uncontrolled Area"
            designLimitEditField.Value = 120 * (3/10);
        case "Public Area"
            designLimitEditField.Value = 20 * (3/10);
        otherwise
            designLimitEditField.Value = 0; % Default or clear value
    end
end
end

% Function to update the design limit based on the contamination checkbox
function updateDesignLimitWithContamination(cbx_contamination, dd, designLimitEditField, cbx_idr)
    % Call setDesignLimit to update based on area selection first
    setDesignLimit(dd, designLimitEditField, cbx_idr);
    
    % If contamination checkbox is checked, adjust the design limit
    if cbx_contamination.Value
        designLimitEditField.Value = designLimitEditField.Value * (10/3) * (1/2); 
    end
end

% Update source data based on selected source
function selectedSource = updateSourceData(sourceDropdown, sourceData)
selectedSource = sourceData.(sourceDropdown.Value);
end

% Function to calculate shielding thickness and update the table
function calculateShieldingThickness(sourceDropdown, activityEditField, doseEditField, rateEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, areaEditField, numberSourcesEditField, sourceData, density, PriceEditField, resultTable, tableData, shieldTable, shieldData, mainFig, cbx, cbx_idr)

% Get the selected source data
selectedSource = sourceData.(sourceDropdown.Value);

% Pre-allocate arrays to store thickness and cost results
transmissionFactor = zeros(1,6);
attenuationFactor = zeros(1,6);
thickness = zeros(3,6);  % 3 materials (Lead, Steel, Concrete), 6 distances
cost = zeros(3,6);       % Same size for cost
DoseRate = zeros(3,6);
InDoseRate = zeros(1,6);

if cbx.Value == 0
    F = 1;
elseif cbx.Value == 1
    F = selectedSource.F;
end

% Check for negative values in input fields
if any([activityEditField.Value, numberSourcesEditField.Value, doseEditField.Value, rateEditField.Value, treatmentsEditField.Value] < 0)
    uialert(mainFig, 'Input values cannot be negative.', 'Input Error');
    return; % Exit the function if negative values are found
end

if cbx_idr.Value
    workload = selectedSource.RAKR * activityEditField.Value * numberSourcesEditField.Value;
    % Set workload to 0 if it is negative
    if workload < 0
        workload = 0;
    end
    workloadValue.Text = sprintf('%.2f μGym^{2}/hour', workload);
    workloadValue.Interpreter = 'tex';
else
    % Calculate the workload
    workload = selectedSource.RAKR * activityEditField.Value * numberSourcesEditField.Value * (doseEditField.Value / (rateEditField.Value * 60)) * treatmentsEditField.Value;

    % Set workload to 0 if it is negative
    if workload < 0
        workload = 0;
    end
    workloadValue.Text = sprintf('%.2f μGym^{2}/hour', workload);
    workloadValue.Interpreter = 'tex';
end

% Loop through the 6 distances and calculate thickness and cost
for i = 1:6
    if cbx_idr.Value
        transmissionFactor(i) = (designLimitEditField{i}.Value * F * distanceEditField{i}.Value^2) / (workload);
    else
        transmissionFactor(i) = (designLimitEditField{i}.Value * F * distanceEditField{i}.Value^2) / (workload * occupationFactorEditField{i}.Value);
    end
    % Check if transmissionFactor is valid; if not, set to 0
    if isnan(transmissionFactor(i)) || transmissionFactor(i) == Inf || transmissionFactor(i) == -Inf || transmissionFactor(i) < 0
        transmissionFactor(i) = 0;
    end

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

        % Check if thickness is valid; if not, set to 0
        if isnan(thickness(j,i)) || thickness(j,i) == Inf || thickness(j,i) == -Inf
            thickness(j,i) = 0;
        end

        % Calculate cost based on material density and price per kg
        % Assuming thickness is in mm
        thickness_mm = ceil(thickness(j,i));
        numberofslabs = areaEditField{i}.Value*10^6/thickness_mm^2;
        volume = thickness_mm^3;  % Volume in m^3
        cost(j,i) = PriceEditField.(material).Value * density.(material) * volume * numberofslabs;

        % Check if cost is valid; if not, set to 0
        if isnan(cost(j,i)) || cost(j,i) == Inf || cost(j,i) == -Inf
            cost(j,i) = 0;
        end

        if cbx_idr.Value
            InDoseRate(i) = designLimitEditField{i}.Value * F * (doseEditField.Value / (rateEditField.Value * 60)) * (workload/8);
        else
            InDoseRate(i) = (activityEditField.Value * numberSourcesEditField.Value * selectedSource.RAKR) / distanceEditField{i}.Value^2;
        end

        % Check if Activity is valid; if not, set to 0
        if isnan(InDoseRate(i)) || InDoseRate(i) == Inf || InDoseRate(i) == -Inf
            InDoseRate(i) = 0;
        end

        DoseRate(j,i) = InDoseRate(i)*exp(-selectedSource.(material)*density.(material)*ceil(thickness(j,i)));

        % Check if Activity is valid; if not, set to 0
        if isnan(DoseRate(j, i)) || DoseRate(j, i) == Inf || DoseRate(j, i) == -Inf
            DoseRate(j, i) = 0;
        end

        % Update the table data for the current material and distance
        tableData{1,1} = sprintf('Lead');
        tableData{2,1} = sprintf('Steel');
        tableData{3,1} = sprintf('Concrete');
        tableData{j,2*i} = sprintf('%.2f mm', ceil(thickness(j,i)));  % Thickness in mm
        tableData{j, 2*i+1} = sprintf('€ %.2f', cost(j,i));        % Cost in EUR

        %Update the shield data for material and distance
        shieldData{1,1} = sprintf('No Shielding');
        shieldData{2,1} = sprintf('Lead Shield');
        shieldData{3,1} = sprintf('Steel Shield');
        shieldData{4,1} = sprintf('Concrete Shield');
        shieldData{1,i+1} = sprintf('%.2e uSv/h', InDoseRate(i));
        shieldData{j+1,i+1} = sprintf('%.2e uSv/h', DoseRate(j,i));

        s1 = uistyle('BackgroundColor','r');
        s2 = uistyle('BackgroundColor','y');
        s3 = uistyle('BackgroundColor','g');

        if InDoseRate(i) < 5 %uSv/h
            addStyle(shieldTable,s3,'cell',[1,i+1]);
        elseif InDoseRate(i) == 5
            addStyle(shieldTable,s2,'cell',[1,i+1]);
        else
            addStyle(shieldTable,s1,'cell',[1,i+1]);
        end

        if DoseRate(j,i) < designLimitEditField{i}.Value/40
            addStyle(shieldTable,s3,'cell',[j+1,i+1]);
        elseif DoseRate(j,i) == designLimitEditField{i}.Value/40
            addStyle(shieldTable,s2,'cell',[j+1,i+1]);
        else
            addStyle(shieldTable,s1,'cell',[j+1,i+1]);
        end
    end
end

% Update the UITable with the new data
resultTable.Data = tableData;
shieldTable.Data = shieldData;

end

% Function to save table data to Excel
function saveToExcel(resultTable, shieldTable, mainFig)

% Open a dialog for the user to select a directory
folderName = uigetdir('', 'Select Folder to Save Excel File');

% Check if the user selected a folder (not canceled)
if folderName == 0
    return; % User canceled the operation
end

% Define the Excel filename
excelFileName = fullfile(folderName, 'BISC.xlsx');

% Convert cell array to table format for export
exportTable = cell2table(resultTable.Data, 'VariableNames', resultTable.ColumnName);
exportTable1 = cell2table(shieldTable.Data, 'VariableNames', shieldTable.ColumnName);

% Write the table to the Excel file
writetable(exportTable, excelFileName, 'Sheet', 1, 'Range', 'A1');
writetable(exportTable1,excelFileName, 'Sheet', 1, 'Range', 'A6');

% Alert user of successful save
uialert(mainFig, 'Data saved successfully!', 'Save Confirmation');

end