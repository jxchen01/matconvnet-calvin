classdef SiftFlowDataset < Dataset
    % SiftFlow dataset
    % Missing labels in test are 10, 12, 17
    % Copyright by Holger Caesar, 2014
    
    methods
        function[obj] = SiftFlowDataset()
            % Call superclass constructor
            obj@Dataset();
            
            % Check that global variable is set
            global glDatasetFolder;
            assert(~isempty(glDatasetFolder));
            
            % Dataset settings
            obj.name = 'SiftFlow';
            obj.path = fullfile(glDatasetFolder, obj.name);
            obj.imageFolder = fullfile('Images', 'spatial_envelope_256x256_static_8outdoorcategories');
            
            % Annotation settings
            annotation = Annotation('semanticLabels');
            annotation.labelFormat = 'mat-labelMap';
            annotation.annotationFolder = 'SemanticLabels';
            annotation.labelFolder = fullfile(annotation.annotationFolder, 'spatial_envelope_256x256_static_8outdoorcategories');
            annotation.imageCount = 2688;
            annotation.labelCount = 33;
            annotation.hasStuffThingLabels = true;
            obj.annotations = annotation;
            
            % Set active annotation
            obj.setActiveAnnotation('semanticLabels');
            
            % Check if dataset folder exists
            if ~exist(obj.path, 'dir'),
                error('Error: Dataset folder not found on disk!');
            end;
        end
        
        function[names, labelCount] = getLabelNames(~)
            names = {'bridge', 'building', 'fence', 'crosswalk', 'sidewalk', 'road', 'field', 'grass', 'plant', 'tree', 'mountain', 'rock', 'desert', 'sand', 'moon', 'sun', 'sky', 'sea', 'river', 'awning', 'balcony', 'door', 'staircase', 'window', 'bird', 'cow', 'person', 'boat', 'car', 'bus', 'pole', 'sign', 'streetlight'};
            labelCount = numel(names);
        end
        
        function[imageSize] = getImageSize(~, ~)
            % [imageSize] = getImageSize(~, ~)
            %
            % Return constant image size.
            
            imageSize = [256, 256];
        end
        
        function[metaPath] = getMetaPath(obj)
            % [metaPath] = getMetaPath(obj)
            %
            % Get path with additional meta data.
            metaPath = [obj.path, filesep, 'Meta'];
        end
        
        function[trainImages, testImages] = getTrainTestLists(obj)
            % [trainImages, testImages] = getTrainTestLists(obj)
            %
            % Get lists of train and test images of this dataset.
            splitFilePath = fullfile(obj.getMetaPath(), 'splits.mat');
            if ~exist(splitFilePath, 'file')
                % Create split file
                imageListTst = readLinesToCell(fullfile(obj.path, 'TestSet1.txt'));
                imageListTst = strrep(imageListTst, 'spatial_envelope_256x256_static_8outdoorcategories\', '');
                imageListTst = strrep(imageListTst, '.jpg', '');
                [imageList, imageCountAll] = obj.getImageList();
                splits.test = find(ismember(imageList, imageListTst));
                splits.train = setdiff((1:imageCountAll)', splits.test);
                
                % Save to disk
                save(splitFilePath, 'splits');
            end
            splitStruct = load(splitFilePath);
            splits = splitStruct.splits;
            trainImages = splits.train;
            testImages = splits.test;
            
            % Check consistency
            assert(numel(trainImages) + numel(testImages) == obj.imageCount);
            assert(numel(unique([trainImages; testImages])) == obj.imageCount)
        end
    end
end