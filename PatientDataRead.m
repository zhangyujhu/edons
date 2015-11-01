% function main()
close all
clear all

n_url='https://physionet.org/physiobank/database/mimic2wdb/RECORDS-neonates';
n_records=strsplit(urlread(n_url));
n_urld='https://physionet.org/physiobank/database/mimic2wdb/';


c={};

allpatients=cell(1,length(n_records));



for i=[1:10]%length(n_records)
    
    record=n_records{i};
    
    recFile=urlread(strcat(n_urld,record,'RECORDS'));%list of all files in record
    disp(i)
    if ~isempty(strfind(recFile,'n'))
        
        info_n=wfdbdesc(strcat('/mimic2wdb/',record,record(4:end-1),'n'));
        
        [tm_n,sig_n]=rdsamp(strcat('/mimic2wdb/',record,record(4:end-1),'n'),[]);
        
        
        
        info=wfdbdesc(strcat('/mimic2wdb/',record));
        
        sigLength=info(1).LengthSamples;
        
        numIter=floor(sigLength/1E5);
        
        tic
        tm=[];
        sig=[];
        
        if numIter ~= 0
            for iter=1:numIter
                
                [tm_temp,sig_temp]=rdsamp(strcat('/mimic2wdb/',record),[],1E5*iter,1E5*(iter-1)+1);
                tm=[tm; tm_temp];
                sig=[sig; sig_temp];
                
                fprintf('iter=%d ',iter)
            end
            
            [tm_temp,sig_temp]=rdsamp(strcat('/mimic2wdb/',record),[],sigLength,1E5  *numIter+1);
            tm=[tm; tm_temp];
            sig=[sig; sig_temp];
            
        else
            [tm, sig]=rdsamp(strcat('/mimic2wdb/',record),[],sigLength);
        end
        
        toc
        
        patiend_data=struct('Time_n',tm_n,'HR',[],'SpO2',[],'Resp_n',[],'NBP_sys',[],'NBP_dias',[], 'NBP_mean',[],'II',[],'III',[],'aVR',[],'Resp',[],'Pleth',[]);
        CH=length(info_n);
        for ch=1:CH
            switch info_n(ch).Description
                case 'HR'
                    patiend_data.HR=sig_n(:,ch);
                case 'SpO2'
                    patiend_data.SpO2=sig_n(:,ch);
                case 'RESP'
                    patiend_data.Resp_n=sig_n(:,ch);
                case 'NBP Sys'
                    patiend_data.NBP_sys=sig_n(:,ch);
                case 'NBP Dias'
                    patiend_data.NBP_dias=sig_n(:,ch);
                case 'NBP Mean'
                    patiend_data.NBP_mean=sig_n(:,ch);
            end
        end
        
        
        CH=length(info);
        for ch=1:CH
            switch info(ch).Description
                case 'II'%put v in later
                    patiend_data.II=sig(:,ch);
                case 'III'
                    patiend_data.III=sig(:,ch);
                case 'AVR'
                    patiend_data.aVR=sig(:,ch);
                case 'RESP'
                    patiend_data.Resp=sig(:,ch);
                case 'PLETH'
                    patiend_data.Pleth=sig(:,ch);
            end
        end
        
        
        allpatients{i}=patiend_data;
        
    end
end