% function main()
close all
clear all

n_url='https://physionet.org/physiobank/database/mimic2wdb/RECORDS-neonates';
n_records=strsplit(urlread(n_url));
n_urld='https://physionet.org/physiobank/database/mimic2wdb/';


c={};

allpatients=cell(1,length(n_records));



for i=[51:100]%length(n_records)
    
    record=n_records{i};
    
    recFile=urlread(strcat(n_urld,record,'RECORDS'));%list of all files in record
    fprintf('patient %d \n',i)
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
                
                fprintf('iter=%d \n',iter)
            end
            
            [tm_temp,sig_temp]=rdsamp(strcat('/mimic2wdb/',record),[],sigLength,1E5  *numIter+1);
            tm=[tm; tm_temp];
            sig=[sig; sig_temp];
            
        else
            [tm, sig]=rdsamp(strcat('/mimic2wdb/',record),[],sigLength);
        end
        
        toc
        
        patient_data=struct('Time_n',tm_n,'HR',[],'SpO2',[],'Resp_n',[],'NBP_sys',[],'NBP_dias',[], 'NBP_mean',[],'Time',tm,'II',[],'III',[],'V',[],'aVR',[],'Resp',[],'Pleth',[]);
        CH=length(info_n);
        for ch=1:CH
            switch info_n(ch).Description
                case 'HR'
                    patient_data.HR=sig_n(:,ch);
                case 'SpO2'
                    patient_data.SpO2=sig_n(:,ch);
                case 'RESP'
                    patient_data.Resp_n=sig_n(:,ch);
                case 'NBP Sys'
                    patient_data.NBP_sys=sig_n(:,ch);
                case 'NBP Dias'
                    patient_data.NBP_dias=sig_n(:,ch);
                case 'NBP Mean'
                    patient_data.NBP_mean=sig_n(:,ch);
            end
        end
        
        
        CH=length(info);
        for ch=1:CH
            switch info(ch).Description
                case 'II'%put v in later
                    patient_data.II=sig(:,ch);
                case 'III'
                    patient_data.III=sig(:,ch);
                case 'V'
                    patient_data.V=sig(:,ch);
                case 'AVR'
                    patient_data.aVR=sig(:,ch);
                case 'RESP'
                    patient_data.Resp=sig(:,ch);
                case 'PLETH'
                    patient_data.Pleth=sig(:,ch);
            end
        end
        
        
        allpatients{i}=patient_data;
        
    end
end

save('PatientData','-v7.3')