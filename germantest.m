clc;

clear all;
close all;
warning off;
cd german
delete 'Thumbs.db';
cd ..
Fd=dir('german');
Fd=char(Fd.name);
sz=size(Fd,1)-2;
h=waitbar(0,'Please wait the system is training');
for ii=1:sz
    cd german
    st=Fd(ii+2,:);
    grp{ii}=st(6:7);
    if st(6:7)=='an'
        gg(ii)=1e-3;
    end
    if st(6:7)=='di'
        gg(ii)=1e-2;
    end
    if st(6:7)=='fe'
        gg(ii)=1e-1;
    end
    if st(6:7)=='ha'
        gg(ii)=1;
    end
    if st(6:7)=='sa'
        gg(ii)=1e1;
    end
    if st(6:7)=='bo'
        gg(ii)=1e2;
    end
    [I Fs]=wavread(st,[1e4 2e4]);
    I=I(:,1);
    cd ..
[E]=endpointdetect(I,Fs);
W=fix(.04*Fs);                 %Window length is 40 ms
SP=.4;                         %Shift percentage is (10ms) %Overlap-Add method works good with this value(.4)
Seg=segment1(E,W,SP);
%-------------------------------------------------
for nn=1:size(Seg,2)
[F0,T,C]=PitchTrackCepstrum(Seg(:,nn),Fs);
LE=sum(Seg(:,nn).^2);
[F T]=spFormantsTrackLpc(Seg(:,nn),Fs);
F1=F(1);F2=F(2);F3=F(3);
[MFC ME] = mfcc(Seg(:,nn),Fs);
fv(:,nn)=[F0 LE F1 F2 F3 MFC' ME']';
end
FV(:,ii)=fv(:);
waitbar(ii/sz);
end
close(h)
[mdel nuu]=mysvmtrain(FV,gg);
sp={'an','di','fe','ha','sa','bo',};
for ii=1:sz
    res=mysvmtest(FV(:,ii)',mdel,nuu);
    rr=sp{res};
    ss(ii)=strcmp(rr,grp{ii});
end
disp(['Recognition rate is ',num2str(sum(ss)/numel(ss)*100)])    



