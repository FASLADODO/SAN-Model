function [ appobj, inappobj ] = scratch_GMM( Dataapp, Datainapp, num_clusters )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[an, ap] = size(Dataapp);
[in, ip] = size(Datainapp);
Sigma = {'diagonal', 'full'};
nSigma = numel(Sigma);
SharedCovariance = {true, false};
SCtext = {'true','false'};
nSC = numel(SharedCovariance);
d = 500;

for f_index = 1:ap
    for s_index = f_index+1:ap
        appx1 = linspace(min(Dataapp(:,f_index)) - 2,max(Dataapp(:,f_index)) + 2,d);
        appx2 = linspace(min(Dataapp(:,s_index)) - 2,max(Dataapp(:,s_index)) + 2,d);
        [appx1grid,appx2grid] = meshgrid(appx1,appx2);
        appX0 = [appx1grid(:) appx2grid(:)];
        
        inappx1 = linspace(min(Datainapp(:,f_index)) - 2,max(Datainapp(:,f_index)) + 2,d);
        inappx2 = linspace(min(Datainapp(:,s_index)) - 2,max(Datainapp(:,s_index)) + 2,d);
        [inappx1grid,inappx2grid] = meshgrid(inappx1,inappx2);
        inappX0 = [inappx1grid(:) inappx2grid(:)];
        
        threshold = sqrt(chi2inv(0.99,2));
        options = statset('MaxIter',1000); % Increase number of EM iterations
        figure;
        c = 1;
        for i = 1:nSigma;
            for j = 1:nSC;
                appobj = fitgmdist(Dataapp(:, [f_index, s_index]),num_clusters,'CovarianceType',Sigma{i},...
                    'SharedCovariance',SharedCovariance{j},'Options',options);
                clusterApp = cluster(appobj,Dataapp(:, [f_index, s_index]));
                appmahalDist = mahal(appobj,appX0);
                
                inappobj = fitgmdist(Datainapp(:, [f_index, s_index]),num_clusters,'CovarianceType',Sigma{i},...
                    'SharedCovariance',SharedCovariance{j},'Options',options);
                clusterInapp = cluster(inappobj,Datainapp(:, [f_index, s_index]));
                inappmahalDist = mahal(inappobj,inappX0);
                
                subplot(2,2,c);
                h1 = gscatter(Dataapp(:,f_index),Dataapp(:,s_index),clusterApp);
                hold on;
                    for m = 1:num_clusters;
                        m
                        appidx = appmahalDist(:,m)<=threshold;
                        %Color = h1(m).Color*0.75 + -0.5*(h1(m).Color - 1);
                        h2 = plot(appX0(appidx,1),appX0(appidx,2),'.','Color', 'c','MarkerSize',1);
                        %hold on
                        %inappidx = inappmahalDist(:,m)<=threshold;
                        %Color = inapph1(m).Color*0.75 + -0.5*(inapph1(m).Color - 1);
                        %inapph2 = plot(inappX0(inappidx,1),inappX0(inappidx,2),'.','Color',Color,'MarkerSize',1);
                        uistack(h2,'bottom');
                        %uistack(inapph2,'bottom');
                    end
                 inapph1 = gscatter(Datainapp(:,f_index),Datainapp(:,s_index),clusterInapp);
                 hold on
                    for h = 1:num_clusters;
                        h
                        inappidx = inappmahalDist(:,h)<=threshold;
                        %Color = inapph1(h).Color*0.5 + -0.25*(inapph1(h).Color - 1);
                        inapph2 = plot(inappX0(inappidx,1),inappX0(inappidx,2),'.','Color','m','MarkerSize',1);
                        uistack(inapph2,'bottom');
                    end
                    
                plot(appobj.mu(:,1),appobj.mu(:,2),'kx','LineWidth',2,'MarkerSize',10)
                plot(inappobj.mu(:,1),inappobj.mu(:,2),'kx','LineWidth',2,'MarkerSize',10)
                title(sprintf('Sigma is %s, SharedCovariance = %s',...
                    Sigma{i},SCtext{j}),'FontSize',8)
                hold off
                c = c + 1;
            end
        end 
    end
end

end

