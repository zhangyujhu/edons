% function main()
close all
clear all

n_url='https://physionet.org/physiobank/database/mimic2wdb/RECORDS-neonates';
n_records=strsplit(urlread(n_url));
n_urld='https://physionet.org/physiobank/database/mimic2wdb/';


c={};
for i=10:10;%length(n_records)
    record=n_records{i};
    info_n=wfdbdesc(strcat('/mimic2wdb/',record,record(4:end-1),'n'));
    [tm_n,sig_n]=rdsamp(strcat('/mimic2wdb/',record,record(4:end-1),'n'),[]);
    
    info=wfdbdesc(strcat('/mimic2wdb/',record));
    [tm,sig]=rdsamp(strcat('/mimic2wdb/',record),[]);
    
    patient_data=struct('Time_n',tm_n,'HR',[],'SpO2',[],'Resp_n',[],'NBP_sys',[],'NBP_dias',[], 'NBP_mean',[],'II',[]);
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
            case 'II'
                patient_data.II=sig(:,ch);
        end
    end
    
 end

