function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 11-Nov-2014 10:27:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui (see VARARGIN)
    addpath(genpath('externalLib'));
    addpath(genpath('variables'));
    
    totalImages = 10;
    handles.figure_width = 100;
    handles.figure_heigth = 40;
    handles.w_extra_heigth = 2.5;

    % Indicates the color used to display the corresponding colors
    handles.colors = ['r' 'g' 'b' 'k' 'y' 'm' 'c' 'w']
    handles.tot_left = 0; % How many points have been selected on the left image
    handles.tot_right = 0; % How many points have been selected on the right image

    handles.left_points = [];
    handles.right_points = [];

    %% Read images and depth data (480 x 640 x channels(5) x totalImages(20))
    % images(:,:,1:3,i) RGB channels for image i
    % images(:,:,4,i) rgb2gray(image i)
    % images(:,:,5,i) depth data for image i
    % images(:,:,6,i) disparity data for image i 
    images=readImages(totalImages,'kinect');
    %figure = axes1
    handles.all_images = images;
    handles.left_image_idx = 1;
    handles.right_image_idx= 8;

    handles.left_image = handles.all_images(:,:,1:3,handles.left_image_idx);
    handles.right_Image = handles.all_images(:,:,1:3,handles.right_image_idx);;

    handles.img_width = size(handles.left_image,2)
    handles.img_heigth = size(handles.left_image,1)

    axes(handles.axes1);
    imshow(uint8(handles.left_image));
    axes(handles.axes2);
    imshow(uint8(handles.right_Image));

    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    pos=get(hObject,'CurrentPoint');
    disp(['You clicked X:',num2str(pos(1)),', Y:',num2str(pos(2))]);
    xwin = pos(1);
    ywin = pos(2);
    
    % Verify that we are clicking inside some of the two windows
    if( ywin > handles.w_extra_heigth &  ...
        ywin < handles.figure_heigth)
        if( xwin < handles.figure_width)
            x = (pos(1)/handles.figure_width)*handles.img_width;
            y = handles.img_heigth-...
                ( (pos(2)-handles.w_extra_heigth)/(handles.figure_heigth-2*handles.w_extra_heigth))*handles.img_heigth;

            disp(['Figure 1 X:',num2str(x),', Y:',num2str(y)]);
            axes(handles.axes1);
            hold on;
            plot(x,y, strcat( handles.colors(1+mod(handles.tot_left, length(handles.colors))), '*'));
            handles.tot_left = handles.tot_left + 1;

            handles.left_points(handles.tot_left,1)  = x;
            handles.left_points(handles.tot_left,2)  = y;
        else
            x = ( (pos(1)-handles.figure_width)/handles.figure_width)*handles.img_width;
            y = handles.img_heigth-...
                ( (pos(2)-handles.w_extra_heigth)/(handles.figure_heigth-2*handles.w_extra_heigth))*handles.img_heigth;

            disp(['Figure 2 X:',num2str(x),', Y:',num2str(y)]);
            axes(handles.axes2);
            hold on;
            plot(x,y, strcat( handles.colors(1+mod(handles.tot_right, length(handles.colors))), '*'));
            handles.tot_right = handles.tot_right + 1;

            handles.right_points(handles.tot_right,1)  = x;
            handles.right_points(handles.tot_right,2)  = y;
        end
        guidata(hObject, handles);
    end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton3.
function pushbutton3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if( handles.tot_left == handles.tot_right )
        if(handles.tot_left < 8)
            disp('You need at least 8 points in each image');
            disp(strcat('You currently have selected only: ', num2str(handles.tot_left)));
        else
            x_l = handles.left_points;
            x_r = handles.right_points;
            save('Points.mat','x_l','x_r');
        end
    else
        disp('There are not the same number of points seleced for the right and left image! ' );
        disp('Plase choose the same number of points to continue');
        disp(strcat('Number of left pts: ', num2str(handles.tot_left)));
        disp(strcat('Number of right pts: ', num2str(handles.tot_right)));
    end
