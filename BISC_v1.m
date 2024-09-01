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

% Numeric edit fields for workload calculations
activityEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 525 50 22], "ValueDisplayFormat", "%.2f");
durationEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 500 50 22], "ValueDisplayFormat", "%.2f");
treatmentsEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 475 50 22], "ValueDisplayFormat", "%.2f");

% Numeric edit fields for transition factor calculations
designLimitEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 450 50 22], "ValueDisplayFormat", "%.2f");
distanceEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 425 50 22], "ValueDisplayFormat", "%.2f");
occupationFactorEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 400 50 22], "ValueDisplayFormat", "%.2f");
workloadEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 350 50 22], "ValueDisplayFormat", "%.1e");
transmissionFactorEditField = uieditfield(shieldingTab, 'numeric', 'Position', [200 325 50 22], "ValueDisplayFormat", "%.1e");

% Labels for workload calculations
activityLabel = uilabel(shieldingTab, 'Text', 'Activity', 'Position', [20, 525, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
activityUnitDropdown = uidropdown(shieldingTab, "Items", ["MBq", "Bq", "kBq", "GBq"], 'Position', [120, 525, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

durationLabel = uilabel(shieldingTab, 'Text', 'Duration', 'Position', [20, 500, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
durationUnitDropdown = uidropdown(shieldingTab, "Items", ["hours", "minutes", "seconds"], 'Position', [120, 500, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

treatmentsLabel = uilabel(shieldingTab, 'Text', 'Treatments', 'Position', [20, 475, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsUnitDropdown = uidropdown(shieldingTab, "Items", ["per week"], 'Position', [120, 475, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels for transition factor calculations
designLimitLabel = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [20, 450, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimitAreaDropdown = uidropdown(shieldingTab, "Items", ["Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [120, 450, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

distanceLabel = uilabel(shieldingTab, 'Text', 'Distance', 'Position', [20, 425, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distanceUnitDropdown = uidropdown(shieldingTab, "Items", ["meters"], 'Position', [120, 425, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

occupationFactorLabel = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [20, 400, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

workloadLabel = uilabel(shieldingTab, 'Text', 'Workload [μGym^2/week]', 'Position', [20, 350, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

transmissionFactorLabel = uilabel(shieldingTab, 'Text', 'Transmission Factor', 'Position', [20, 325, 140, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels and fields to display calculated thickness
thicknessLabels = struct();
thicknessLabels.Lead = uilabel(shieldingTab, 'Text', 'Lead Thickness [mm]:', 'Position', [20, 300, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Steel = uilabel(shieldingTab, 'Text', 'Steel Thickness [mm]:', 'Position', [20, 275, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Concrete = uilabel(shieldingTab, 'Text', 'Concrete Thickness [mm]:', 'Position', [20, 250, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels to display calculated values
thicknessValues = struct();
thicknessValues.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 300, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 275, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 250, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Button for calculation
calcButton = uibutton(shieldingTab, 'Position', [20 375 140 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadEditField, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorEditField, thicknessValues, sourceData);

% Assigning callbacks for dropdowns
activityUnitDropdown.ValueChangedFcn = @(dd, event) convertActivityUnit(dd, activityEditField);
durationUnitDropdown.ValueChangedFcn = @(dd, event) convertDurationUnit(dd, durationEditField);
treatmentsUnitDropdown.ValueChangedFcn = @(dd, event) convertTreatmentsUnit(dd, treatmentsEditField);
designLimitAreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimitEditField);

% Callback functions for unit conversion
function convertActivityUnit(unitDropdown, activityEditField)
    switch unitDropdown.Value
        case 'MBq'
            % Base unit
        case 'kBq'
            activityEditField.Value = activityEditField.Value * 1e3;
        case 'GBq'
            activityEditField.Value = activityEditField.Value * 1e-3;
        case 'Bq'
            activityEditField.Value = activityEditField.Value * 1e6;
    end
end

function convertDurationUnit(unitDropdown, durationEditField)
    switch unitDropdown.Value
        case 'hours'
            % Base unit
        case 'minutes'
            durationEditField.Value = durationEditField.Value * 60;
        case 'seconds'
            durationEditField.Value = durationEditField.Value * 3600;
    end
end

function convertTreatmentsUnit(unitDropdown, treatmentsEditField)
    % Placeholder for treatment unit conversion if needed
end

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
    % Additional functionality when source changes can be added here
end

% Callback function for shielding thickness calculation
function calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadEditField, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorEditField, thicknessValues, sourceData)
    selectedSource = sourceData.(sourceDropdown.Value);
    workloadEditField.Value = selectedSource.RAKR * activityEditField.Value * durationEditField.Value * treatmentsEditField.Value;
    transmissionFactorEditField.Value = (designLimitEditField.Value * distanceEditField.Value^2) / (workloadEditField.Value * occupationFactorEditField.Value);

    % Calculate the attenuation factor
    attenuationFactor = log10(1 / transmissionFactorEditField.Value);

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
    end
end
