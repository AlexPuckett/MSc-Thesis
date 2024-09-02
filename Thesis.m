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
sourceLabel = uilabel(shieldingTab, 'Text', 'Source', 'Position', [790, 550, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown = uidropdown(shieldingTab, "Items", fieldnames(sourceData), 'Position', [890, 550, 130, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
sourceDropdown.ValueChangedFcn = @(dd, event) updateSourceData(dd, sourceData);

% Numeric edit fields for workload calculations
activityEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 525 50 22], "ValueDisplayFormat", "%.2f");
durationEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 500 50 22], "ValueDisplayFormat", "%.2f");
treatmentsEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 475 50 22], "ValueDisplayFormat", "%.2f");

% Numeric edit fields for transition factor calculations
designLimitEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 450 50 22], "ValueDisplayFormat", "%.2f");
distanceEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 425 50 22], "ValueDisplayFormat", "%.2f");
occupationFactorEditField = uieditfield(shieldingTab, 'numeric', 'Position', [970 400 50 22], "ValueDisplayFormat", "%.2f");
workloadValue = uilabel(shieldingTab, 'Text', '-', 'Position', [960, 350, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
transmissionFactorValue = uilabel(shieldingTab, 'Text', '-', 'Position', [960, 325, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels for workload calculations
activityLabel = uilabel(shieldingTab, 'Text', 'Activity', 'Position', [790, 525, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
activityUnitDropdown = uidropdown(shieldingTab, "Items", ["MBq", "Bq", "kBq", "GBq"], 'Position', [890, 525, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

durationLabel = uilabel(shieldingTab, 'Text', 'Duration', 'Position', [790, 500, 50, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
durationUnitDropdown = uidropdown(shieldingTab, "Items", ["hours", "minutes", "seconds"], 'Position', [890, 500, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

treatmentsLabel = uilabel(shieldingTab, 'Text', 'Treatments', 'Position', [790, 475, 120, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
treatmentsUnitDropdown = uidropdown(shieldingTab, "Items", ["per week"], 'Position', [890, 475, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels for transition factor calculations
designLimitLabel = uilabel(shieldingTab, 'Text', 'Design Limit [μGy]', 'Position', [790, 450, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
designLimitAreaDropdown = uidropdown(shieldingTab, "Items", ["Controlled Area", "Uncontrolled Area", "Public Area"], 'Position', [890, 450, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

distanceLabel = uilabel(shieldingTab, 'Text', 'Distance', 'Position', [790, 425, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
distanceUnitDropdown = uidropdown(shieldingTab, "Items", ["meters"], 'Position', [890, 425, 70, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

occupationFactorLabel = uilabel(shieldingTab, 'Text', 'Occupation Factor', 'Position', [790, 400, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

workloadLabel = uilabel(shieldingTab, 'Text', 'Workload [μGym^2/week]', 'Position', [790, 350, 125, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

transmissionFactorLabel = uilabel(shieldingTab, 'Text', 'Transmission Factor', 'Position', [790, 325, 140, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels and fields to display calculated thickness
thicknessLabels = struct();
thicknessLabels.Lead = uilabel(shieldingTab, 'Text', 'Lead Thickness [mm]:', 'Position', [790, 300, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Steel = uilabel(shieldingTab, 'Text', 'Steel Thickness [mm]:', 'Position', [790, 275, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessLabels.Concrete = uilabel(shieldingTab, 'Text', 'Concrete Thickness [mm]:', 'Position', [790, 250, 150, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Labels to display calculated values
thicknessValues = struct();
thicknessValues.Lead = uilabel(shieldingTab, 'Text', '-', 'Position', [960, 300, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Steel = uilabel(shieldingTab, 'Text', '-', 'Position', [960, 275, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
thicknessValues.Concrete = uilabel(shieldingTab, 'Text', '-', 'Position', [960, 250, 100, 22], 'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

% Button for calculation
calcButton = uibutton(shieldingTab, 'Position', [790 375 140 22], 'Text', 'Calculate');
calcButton.ButtonPushedFcn = @(btn, event) calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorValue, thicknessValues, sourceData);

% Adding a button to load the floor plan image
b_loadImage = uibutton(shieldingTab,'Position',[630 550 140 22],'Text','Load Floor Plan');
ax = uiaxes(shieldingTab,'Position',[30 130 600 450]); % Axes to display the floor plan

% Adding a button to detect walls
b_detectWalls = uibutton(shieldingTab,'Position',[630 525 140 22],'Text','Detect Walls');
b_detectWalls.Enable = 'off'; % Disable until an image is loaded

% Adding a button to add points
b_addPoint = uibutton(shieldingTab, 'Position', [630 500 140 22], 'Text', 'Add Point');
b_addPoint.Enable = 'off'; % Disable until an image is loaded

% Callback to load image
b_loadImage.ButtonPushedFcn = @(btn,event) loadImage(ax, b_detectWalls, b_addPoint);

% Callback to detect walls
b_detectWalls.ButtonPushedFcn = @(btn,event) detectWalls(ax);

% Callback to add points
b_addPoint.ButtonPushedFcn = @(btn, event) enablePointAdding(ax);

% Assigning callbacks for dropdowns
activityUnitDropdown.ValueChangedFcn = @(dd, event) convertActivityUnit(dd, activityEditField);
durationUnitDropdown.ValueChangedFcn = @(dd, event) convertDurationUnit(dd, durationEditField);
treatmentsUnitDropdown.ValueChangedFcn = @(dd, event) convertTreatmentsUnit(dd, treatmentsEditField);
designLimitAreaDropdown.ValueChangedFcn = @(dd, event) setDesignLimit(dd, designLimitEditField);

% FUNCTIONS
% Function to load an image
function loadImage(ax, b_detectWalls, b_addPoint)
    % Let user select an image file
    [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'All Image Files'}, 'Select Floor Plan');
    if isequal(file, 0)
        return;
    end

    % Display the image on the axes
    img = imread(fullfile(path, file));
    imshow(img, 'Parent', ax);

    % Enable the detect walls and add point buttons
    b_detectWalls.Enable = 'on';
    b_addPoint.Enable = 'on';
end

% Function to detect walls in the image and solidify them
function detectWalls(ax)
    % Retrieve the image from the axes
    imgHandle = findobj(ax, 'Type', 'image');
    if isempty(imgHandle)
        return;
    end

    img = imgHandle.CData; % Extract image data

    % Convert to grayscale if it's a color image
    if size(img, 3) == 3
        grayImg = rgb2gray(img);
    else
        grayImg = img;
    end

    % Invert the image so walls (black lines) become white on a black background
    invertedImg = imcomplement(grayImg);

    % Use edge detection to enhance wall lines
    edges = edge(invertedImg, 'Canny', 0.2);  % Adjust the threshold for better detection

    % Dilate the edges to make the walls thicker and more solid
    se = strel('line', 2, 0);  % Line structuring element for horizontal lines
    dilatedEdges = imdilate(edges, se);
    se = strel('line', 2, 90);  % Line structuring element for vertical lines
    dilatedEdges = imdilate(dilatedEdges, se);

    % Close gaps in the walls
    se = strel('disk', 2);  % Disk structuring element to close gaps
    closedWalls = imclose(dilatedEdges, se);

    % Fill any holes within the wall structures
    filledWalls = imfill(closedWalls, 'holes');

    % Remove small noise
    cleanWalls = bwareaopen(filledWalls, 50);  % Remove small objects (noise)

    % Display the processed binary image with solidified walls
    imshow(cleanWalls, 'Parent', ax);

    % Set HitTest of the image to 'off' to ensure clicks are registered by the axes
    imgHandle = findobj(ax, 'Type', 'image');
    set(imgHandle, 'HitTest', 'off');

    % Enable point adding after wall detection
    ax.PickableParts = 'all';
end

% Function to enable adding points on the image
function enablePointAdding(ax)

    % Reset any previous button-down functions
    ax.ButtonDownFcn = [];
    
    % Set the ButtonDownFcn of the axes to allow point addition
    ax.ButtonDownFcn = @(src, event) addPoint(src, event);
end

% Function to add a point on the image
function addPoint(src, event)
    % Get the current point coordinates
    cp = event.IntersectionPoint(1:2);

    % Retrieve the image dimensions
    imgHandle = findobj(src, 'Type', 'image');
    img = imgHandle.CData;
    [imgHeight, imgWidth, ~] = size(img);
    
    % Normalize the coordinates
    normX = cp(1) / imgWidth;
    normY = 1 - (cp(2) / imgHeight);

    % Remove any previous point
    oldPoints = findobj(src, 'Type', 'line');
    delete(oldPoints);

    % Plot the point on the axes
    hold(src, 'on'); % Keep existing image
    plot(src, cp(1), cp(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    hold(src, 'off');
    
    % Display the coordinates in the command window (or use for further processing)
    disp(['Point added at: X=', num2str(normX), ', Y=', num2str(normY)]);

end

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
end

% Callback function for shielding thickness calculation
function calculateShieldingThickness(sourceDropdown, activityEditField, durationEditField, treatmentsEditField, workloadValue, designLimitEditField, distanceEditField, occupationFactorEditField, transmissionFactorValue, thicknessValues, sourceData)
    selectedSource = sourceData.(sourceDropdown.Value);
    workload = selectedSource.RAKR * activityEditField.Value * durationEditField.Value * treatmentsEditField.Value;
    workloadValue.Text = sprintf('%.2f', workload);
    transmissionFactor = (designLimitEditField.Value * distanceEditField.Value^2) / (workload * occupationFactorEditField.Value);
    transmissionFactorValue.Text = sprintf('%.2f', transmissionFactor);

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
    end
end