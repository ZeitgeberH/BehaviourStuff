function Res=lickPlot(Datadir,preTrialStart,postTrialStart)
%Datadir='/home/miluky99/Downloads/ChenQian/MouseShank3B_Dlx56_G6f-A3_08-Jan-2019';
if nargin <2
    preTrialStart=1000; %% number of samples before trial start
    postTrialStart=2000; %% number of samples after trial start
end

cd(Datadir);
sessionInfo=dir('session_*.mat');
load(sessionInfo.name)
trial_filesInfo=dir('trial_*.mat');
Ntrial=length(trial_filesInfo);
trial_names={trial_filesInfo.name};
trial_time=[trial_filesInfo.datenum];
[time_srt,time_idx]=sort(trial_time);
%%
% SessionData=[];
figure('name',[session.mouse ' ' session.date]); hold on;
Res.stimTrials=[];
Res.noStimTrials=[];
% Ntrial=331
for i=1:Ntrial,
    load(trial_names{time_idx(i)});
    trial_syn=find(data(:,1)>2.5,1,'last');
    reward_win=find(data(trial_syn-preTrialStart:trial_syn+postTrialStart,3)>4.0); %% rewarding window
    data_trc=diff(data(trial_syn-preTrialStart:trial_syn+postTrialStart,4));
    data_trc(data_trc<4)=0;
    
    [pks,locs]=findpeaks(data_trc);
    if ~isempty(reward_win)  %% this should not be empty?
        lick_in_rWin=intersect(reward_win,locs); %% look for licks during reward window
    else
        reward_win=[preTrialStart preTrialStart+round(session.reward_duration*session.Hz)];
        lick_in_rWin=intersect(reward_win,locs); %% look for licks during reward window
    end;
    
    if session.stim_amplitude(i)<0 %% whisker stimulation trial
        dotC='k';  %% hit trial
    else
        dotC='r';  %% false alarm trial
    end
    
    
    if session.stim_amplitude(i)~= 0  %% stimulation trial
        if isempty(lick_in_rWin)
            Res.stimTrials(end+1)=0;  %% miss
        else
            Res.stimTrials(end+1)=1;  %% hit
        end
    else   %% none-stimulationt rial
        if isempty(lick_in_rWin)
            Res.noStimTrials(end+1)=0;  %% correct rejection
        else
            Res.noStimTrials(end+1)=1;  %% false positive
        end
        
    end
    plot((locs-preTrialStart)/session.Hz,ones(1,length(locs))*i, '.','MarkerFaceColor',dotC,'MarkerEdgeColor',dotC);
    
    
    %         line(([reward_win(1) reward_win(1)]-preTrialStart)/session.Hz,[i i+1],'linestyle','--','color','g')
    
    line(([reward_win(end) reward_win(end)]-preTrialStart)/session.Hz,[i i+1],'linestyle','--','color','g')
    
end
line([0 0],[0 Ntrial],'linestyle','--','color','k');
axis ij
xlabel('Time (s)');
ylabel('Trial number');

%%% dprime
Res.dprime = norminv(mean(Res.stimTrials)) - norminv(mean(Res.noStimTrials));

title([session.mouse ' ' session.date ' dprime=' num2str(Res.dprime )],'Interpreter', 'none');

Res.session=session;

