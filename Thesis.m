clear all
clc

%Creating Tabs and properties
fig = uifigure("Name","BISC"); %Brachytherapy Infrastructure Shielding Calculations
fig.Resize = 'off'; % Disable resizing
fig.WindowState = 'normal'; % Ensure the window is in normal state (not maximized or minimized)
set(fig, 'Units', 'normalized', 'Position',  [0.1, 0.1, 0.8, 0.8]);

tg = uitabgroup(fig,'Units','normalized',"Position",[0,0,1,1]);
t1 = uitab(tg,"Title","Shielding Thickness");
t1.Scrollable = "on";

%Creatring the Numeric Edit Fields for Workload Calculations
efR = uieditfield(t1,'numeric','Position',[1000 550 50 22],"ValueDisplayFormat","%.2f"); %RAKR
efA = uieditfield(t1,'numeric','Position',[1000 525 50 22],"ValueDisplayFormat","%.2f"); %Activity
efD = uieditfield(t1,'numeric','Position',[1000 500 50 22],"ValueDisplayFormat","%.2f"); %Duration
efTr = uieditfield(t1,'numeric','Position',[1000 475 50 22],"ValueDisplayFormat","%.2f"); %Treatments

%Creatring the Numeric Edit Fields for Transition Factor Calculations
efP = uieditfield(t1,'numeric','Position',[1000 450 50 22],"ValueDisplayFormat","%.2f"); %Design Limit
efd = uieditfield(t1,'numeric','Position',[1000 425 50 22],"ValueDisplayFormat","%.2f"); %distance from barrier
efT = uieditfield(t1,'numeric','Position',[1000 400 50 22],"ValueDisplayFormat","%.2f"); %Occupation Factor
efw = uieditfield(t1,'numeric','Position',[1000 350 50 22],"ValueDisplayFormat","%.0e"); %Workload
efB = uieditfield(t1,'numeric','Position',[1000 325 50 22],"ValueDisplayFormat","%.0e"); %Transmission Factor

%Creating the Edit Field Labels for Workload Calculations
lR = uilabel(t1, 'Text', 'RAKR', 'Position', [830, 550, 125, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor','black');
dR = uidropdown(t1, "Items", ["μGym^2/MBqh","mGym^2/MBqh","Gym^2/MBqh"], 'Position', [920, 550, 70, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

lA = uilabel(t1, 'Text', 'Activity', 'Position', [830, 525, 100, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
dA = uidropdown(t1, "Items", ["GBq","MBq","kBq","Bq"], 'Position', [920, 525, 70, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

lD = uilabel(t1, 'Text', 'Duration', 'Position', [830 500 50 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
dD = uidropdown(t1, "Items", ["hours","minutes","seconds"], 'Position', [920 500 70 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

lTr = uilabel(t1, 'Text', 'Treatments', 'Position', [830, 475, 120, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');
dTr = uidropdown(t1, "Items", ["Tre/week"], 'Position', [920, 475, 70, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

%Creating the Edit Field Labels for Transmission Factor Calculation
lP = uilabel(t1, 'Text', 'Design Limit [μGy]', 'Position', [830, 450, 125, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor','black');
dP = uidropdown(t1, "Items", ["Controlled Area","Uncontrolled Area","Public Area"], 'Position', [920, 450, 70, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

ld = uilabel(t1, 'Text', 'Distance', 'Position', [830, 425, 125, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor','black');
dd = uidropdown(t1, "Items", ["meters"], 'Position', [920, 425, 70, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

lT = uilabel(t1, 'Text', 'Occupation Factor', 'Position', [830, 400, 125, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor','black');

lw = uilabel(t1, 'Text', 'Workload [μGym^2/week]', 'Position', [830, 350, 125, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor','black');

B = uilabel(t1, 'Text', 'TransmissionFactor', 'Position', [830, 325, 140, 22],'FontWeight', 'bold', 'FontSize', 10, 'FontColor', 'black');

%Creating button and its Callback for Workload Calcualtion
b = uibutton(t1,'Position',[830 375 140 22],'Text','Calc');
b.ButtonPushedFcn = @(btn,event) calculateValue(efR, efA, efD, efTr, efw, efP, efd, efT, efB);

% Adding a button to load the floor plan image
b_loadImage = uibutton(t1,'Position',[650 550 140 22],'Text','Load Floor Plan');
ax = uiaxes(t1,'Position',[30 130 600 450]); % Axes to display the floor plan

% Adding a button to detect walls
b_detectWalls = uibutton(t1,'Position',[650 525 140 22],'Text','Detect Walls');
b_detectWalls.Enable = 'off'; % Disable until an image is loaded

% Adding a button to add points
b_addPoint = uibutton(t1, 'Position', [650 500 140 22], 'Text', 'Add Point');
b_addPoint.Enable = 'off'; % Disable until an image is loaded

% Callback to load image
b_loadImage.ButtonPushedFcn = @(btn,event) loadImage(ax, b_detectWalls, b_addPoint);

% Callback to detect walls
b_detectWalls.ButtonPushedFcn = @(btn,event) detectWalls(ax);

% Callback to add points
b_addPoint.ButtonPushedFcn = @(btn, event) enablePointAdding(ax);

% Assigning callbacks for dropdowns to handle unit conversion
dR.ValueChangedFcn = @(dd,event) unitConversionRAKR(dd, efR);
dA.ValueChangedFcn = @(dd,event) unitConversionActivity(dd, efA);
dD.ValueChangedFcn = @(dd,event) unitConversionDuration(dd, efD);
dTr.ValueChangedFcn = @(dd,event) unitConversionTreatments(dd, efTr);
dP.ValueChangedFcn = @(dd,event) unitConversionDesignLimit(dd, efP);

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

% Function to detect walls in the image
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

% Callback Functions for unit conversion
function unitConversionRAKR(dd, efR)
    switch dd.Value
        case 'μGym^2/MBqh'
            efR.Value = efR.Value; % Assuming μGym^2/MBqh is the base unit, no conversion needed
        case 'mGym^2/MBqh'
            efR.Value = efR.Value * 1000;
        case 'Gym^2/MBqh'
            efR.Value = efR.Value * 1e6;
        otherwise
    end
end

function unitConversionActivity(dd, efA)
    switch dd.Value
        case 'Bq'
            efA.Value = efA.Value; % Assuming Bq is the base unit, no conversion needed
        case 'kBq'
            efA.Value = efA.Value * 1e3;
        case 'MBq'
            efA.Value = efA.Value * 1e6;
        case 'GBq'
            efA.Value = efA.Value * 1e9;
        otherwise
    end
end

function unitConversionDuration(dd, efD)
    switch dd.Value
        case 'hours'
            efD.Value = efD.Value; % Assuming seconds is the base unit, no conversion needed
        case 'minutes'
            efD.Value = efD.Value * 60;
        case 'seconds'
            efD.Value = efD.Value * 3600;
        otherwise
    end
end

function unitConversionDesignLimit(dd, efP)
    switch dd.Value
        case "Controlled Area"
            efP.Value = 200;
        case "Uncontrolled Area"
            efP.Value = 60;
        case "Public Area"
            efP.Value = 6;
        otherwise
    end
end

%Callback Function for Workload and Transmission Factor Calculation
function calculateValue(efR, efA, efD, efTr, efw, efP, efd, efT, efB)
    efw.Value = efR.Value * efA.Value * efD.Value * efTr.Value;
    efB.Value = (efP.Value*efd.Value^2)/(efw.Value*efT.Value);
end