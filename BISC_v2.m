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

% Labels and Edit Fields for transmition factor calculations
designLimit1Label = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [360, 525, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit1AreaDropdown = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [460, 525, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit2Label = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [360, 500, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit2AreaDropdown = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [460, 500, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit3Label = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [360, 475, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit3AreaDropdown = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [460, 475, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit4Label = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [360, 450, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimit4AreaDropdown = uidropdown(shieldingTab, "Items", ["Select", "Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [460, 450, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

distance1Label = uilabel(shieldingTab, 'Text', 'Distance1 [m]', 'Position', [200, 525, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distance2Label = uilabel(shieldingTab, 'Text', 'Distance2 [m]', 'Position', [200, 500, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distance3Label = uilabel(shieldingTab, 'Text', 'Distance3 [m]', 'Position', [200, 475, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distance4Label = uilabel(shieldingTab, 'Text', 'Distance4 [m]', 'Position', [200, 450, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

occupationFactor1Label = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [620, 525, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
occupationFactor2Label = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [620, 500, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
occupationFactor3Label = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [620, 475, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
occupationFactor4Label = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [620, 450, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

workloadLabel = uilabel(shieldingTab, 'Text', 'Workload [μGym^2/week]', 'Position', [20, 400, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
workloadValue = uilabel(shieldingTab, 'Text', '-', 'Position', [170, 400, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

designLimit1EditField = uieditfield(shieldingTab, 'numeric', 'Position', [540, 525, 50, 22], "ValueDisplayFormat", "%.2f");
designLimit2EditField = uieditfield(shieldingTab, 'numeric', 'Position', [540, 500, 50, 22], "ValueDisplayFormat", "%.2f");
designLimit3EditField = uieditfield(shieldingTab, 'numeric', 'Position', [540, 475, 50, 22], "ValueDisplayFormat", "%.2f");
designLimit4EditField = uieditfield(shieldingTab, 'numeric', 'Position', [540, 450, 50, 22], "ValueDisplayFormat", "%.2f");

distance1EditField = uieditfield(shieldingTab, 'numeric', 'Position', [280, 525, 50, 22], "ValueDisplayFormat", "%.2f");
distance2EditField = uieditfield(shieldingTab, 'numeric', 'Position', [280, 500, 50, 22], "ValueDisplayFormat", "%.2f");
distance3EditField = uieditfield(shieldingTab, 'numeric', 'Position', [280, 475, 50, 22], "ValueDisplayFormat", "%.2f");
distance4EditField = uieditfield(shieldingTab, 'numeric', 'Position', [280, 450, 50, 22], "ValueDisplayFormat", "%.2f");

occupationFactor1EditField = uieditfield(shieldingTab, 'numeric', 'Position', [715, 525, 50, 22], "ValueDisplayFormat", "%.2f");
occupationFactor2EditField = uieditfield(shieldingTab, 'numeric', 'Position', [715, 500, 50, 22], "ValueDisplayFormat", "%.2f");
occupationFactor3EditField = uieditfield(shieldingTab, 'numeric', 'Position', [715, 475, 50, 22], "ValueDisplayFormat", "%.2f");
occupationFactor4EditField = uieditfield(shieldingTab, 'numeric', 'Position', [715, 450, 50, 22], "ValueDisplayFormat", "%.2f");

% Labels and Edit Fiels for Material Prices
ConcretePriceLabel = uilabel(shieldingTab, "Text", "Concrete Price [Eu/Kg]", "Position", [795, 525, 110, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
SteelPriceLabel = uilabel(shieldingTab, "Text", "Steel Price [Eu/Kg]", "Position", [795, 500, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
LeadPriceLabel = uilabel(shieldingTab, "Text", "Lead Price [Eu/Kg]", "Position", [795, 475, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

PriceEditField = struct();
PriceEditField.Concrete = uieditfield(shieldingTab, 'numeric', 'Position', [910, 525, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Steel = uieditfield(shieldingTab, 'numeric', 'Position', [910, 500, 50, 22], "ValueDisplayFormat", "%.2f");
PriceEditField.Lead = uieditfield(shieldingTab, 'numeric', 'Position', [910, 475, 50, 22], "ValueDisplayFormat", "%.2f");

% Labels and fields to display calculated thickness
Distance1Label = uilabel(shieldingTab, 'Text', 'Distance1', 'Position', [320, 400, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Distance2Label = uilabel(shieldingTab, 'Text', 'Distance2', 'Position', [440, 400, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Distance3Label = uilabel(shieldingTab, 'Text', 'Distance3', 'Position', [560, 400, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Distance4Label = uilabel(shieldingTab, 'Text', 'Distance4', 'Position', [680, 400, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist1ThicknessLabel = uilabel(shieldingTab, 'Text', 'Thickness mm', 'Position', [290, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist2ThicknessLabel = uilabel(shieldingTab, 'Text', 'Thickness mm', 'Position', [410, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist3ThicknessLabel = uilabel(shieldingTab, 'Text', 'Thickness mm', 'Position', [530, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist4ThicknessLabel = uilabel(shieldingTab, 'Text', 'Thickness mm', 'Position', [650, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist1CostLabel = uilabel(shieldingTab, 'Text', 'Cost', 'Position', [365, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist2CostLabel = uilabel(shieldingTab, 'Text', 'Cost', 'Position', [485, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist3CostLabel = uilabel(shieldingTab, 'Text', 'Cost', 'Position', [605, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
Dist4CostLabel = uilabel(shieldingTab, 'Text', 'Cost', 'Position', [725, 375, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

thicknessLabels = struct();
thicknessLabels.Lead = uilabel(shieldingTab, 'Text', 'Lead', 'Position', [230, 350, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Steel = uilabel(shieldingTab, 'Text', 'Steel', 'Position', [230, 325, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Concrete = uilabel(shieldingTab, 'Text', 'Concrete', 'Position', [230, 300, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

thicknessValues1 = struct();
thicknessValues1.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [310, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues1.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [310, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues1.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [310, 300, 500, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

thicknessValues2 = struct();
thicknessValues2.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [430, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues2.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [430, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues2.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [430, 300, 500, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

thicknessValues3 = struct();
thicknessValues3.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [550, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues3.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [550, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues3.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [550, 300, 500, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

thicknessValues4 = struct();
thicknessValues4.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [670, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues4.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [670, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues4.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [670, 300, 500, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

priceValues1 = struct();
priceValues1.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [360, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues1.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [360, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues1.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [360, 300, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

priceValues2 = struct();
priceValues2.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [480, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues2.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [480, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues2.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [480, 300, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

priceValues3 = struct();
priceValues3.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [600, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues3.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [600, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues3.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [600, 300, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

priceValues4 = struct();
priceValues4.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [720, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues4.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [720, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
priceValues4.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [720, 300, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Calculating shielding thickness and updating the table
calcButton = uibutton(shieldingTab, 'Position', [810, 450, 100, 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimit1EditField, designLimit2EditField, designLimit3EditField, designLimit4EditField, distance1EditField, distance2EditField, distance3EditField, distance4EditField, occupationFactor1EditField, occupationFactor2EditField, occupationFactor3EditField, occupationFactor4EditField, thicknessValues1, thicknessValues2, thicknessValues3, thicknessValues4, priceValues1, priceValues2, priceValues3, priceValues4, numberSourcesEditField, sourceData, density, PriceEditField);

% Assigning callbacks for dropdowns
designLimit1AreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimit1EditField);
designLimit2AreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimit2EditField);
designLimit3AreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimit3EditField);
designLimit4AreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimit4EditField);

function setDesignLimit(areaDropdown, designLimit1EditField, designLimit2EditField, designLimit3EditField, designLimit4EditField)
    switch areaDropdown.Value
        case "Controlled Area"
            designLimit1EditField.Value = 200;
            designLimit2EditField.Value = 200;
            designLimit3EditField.Value = 200;
            designLimit4EditField.Value = 200;
        case "Uncontrolled Area"
            designLimit1EditField.Value = 60;
            designLimit2EditField.Value = 60;
            designLimit3EditField.Value = 60;
            designLimit4EditField.Value = 60;
        case "Public Area"
            designLimit1EditField.Value = 6;
            designLimit2EditField.Value = 6;
            designLimit3EditField.Value = 6;
            designLimit4EditField.Value = 6;
    end
end

% Update source data based on selected source
function updateSourceData(sourceDropdown, sourceData)
    selectedSource = sourceData.(sourceDropdown.Value);
    % Additional functionality when source changes can be added here
end

% Function to calculate shielding thickness and update the table
function calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimit1EditField, designLimit2EditField, designLimit3EditField, designLimit4EditField, distance1EditField, distance2EditField, distance3EditField, distance4EditField, occupationFactor1EditField, occupationFactor2EditField, occupationFactor3EditField, occupationFactor4EditField, thicknessValues1, thicknessValues2, thicknessValues3, thicknessValues4, priceValues1, priceValues2, priceValues3, priceValues4, numberSourcesEditField, sourceData, density, PriceEditField)
    selectedSource = sourceData.(sourceDropdown.Value);
    workload = selectedSource.RAKR * activityEditField.Value * numberSourcesEditField.Value * durationEditField.Value * treatmentsEditField.Value;
    workloadValue.Text = sprintf('%.2f', workload);

    % Calculate and display thickness for each material
    materials = fieldnames(selectedSource.TVLe);
        for j = 1:length(materials)
            material = materials{j};
            TVLe = selectedSource.TVLe.(material);
            TVL1 = selectedSource.TVL1.(material);

            if isempty(TVL1)
                TVL1 = 0; % Set TVL1 to zero if not provided
            end

            transmissionFactor1 = (designLimit1EditField.Value * distance1EditField.Value^2) / (workload * occupationFactor1EditField.Value);
            attenuationFactor1= log10(1 / transmissionFactor1);
            % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
            thickness1 = TVL1 + (attenuationFactor1 - 1) * TVLe;
            thicknessValues1.(material).Text = sprintf('%.2f', thickness1);
            price1 = PriceEditField.(material).Value * density.(material) * thickness1^3;
            priceValues1.(material).Text = sprintf('€ %.2f', price1);

            transmissionFactor2 = (designLimit2EditField.Value * distance2EditField.Value^2) / (workload * occupationFactor2EditField.Value);
            attenuationFactor2= log10(1 / transmissionFactor2);
            % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
            thickness2 = TVL1 + (attenuationFactor2 - 1) * TVLe;
            thicknessValues2.(material).Text = sprintf('%.2f', thickness2);
            price2 = PriceEditField.(material).Value * density.(material) * thickness2^3;
            priceValues2.(material).Text = sprintf('€ %.2f', price2);

            transmissionFactor3 = (designLimit3EditField.Value * distance3EditField.Value^2) / (workload * occupationFactor3EditField.Value);
            attenuationFactor3= log10(1 / transmissionFactor3);
            % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
            thickness3 = TVL1 + (attenuationFactor3 - 1) * TVLe;
            thicknessValues3.(material).Text = sprintf('%.2f', thickness3);
            price3 = PriceEditField.(material).Value * density.(material) * thickness3^3;
            priceValues3.(material).Text = sprintf('€ %.2f', price3);

            transmissionFactor4 = (designLimit4EditField.Value * distance4EditField.Value^2) / (workload * occupationFactor4EditField.Value);
            attenuationFactor4= log10(1 / transmissionFactor4);
            % Calculate thickness: thickness = TVL1 + (attenuationFactor - 1) * TVLe
            thickness4 = TVL1 + (attenuationFactor4 - 1) * TVLe;
            thicknessValues4.(material).Text = sprintf('%.2f', thickness4);
            price4 = PriceEditField.(material).Value * density.(material) * thickness4^3;
            priceValues4.(material).Text = sprintf('€ %.2f', price4);
        end
end
