function PlotSortedModes(floSol)
    OOP.k = [];
    OOP.f = [];
    IPX.k = [];
    IPX.f = [];
    IPY.k = [];
    IPY.f = [];
    Tilt.k = [];
    Tilt.f = [];
    Trash.k = [];
    Trash.f = [];
    for i = 1:size(floSol,2)
        OOP.k = [OOP.k,floSol(i).OutOfPlane.k];
        OOP.f = [OOP.f,abs(floSol(i).OutOfPlane.freq)];
        IPX.k = [IPX.k,floSol(i).InPlane_x.k];
        IPX.f = [IPX.f,abs(floSol(i).InPlane_x.freq)];
        IPY.k = [IPY.k,floSol(i).InPlane_y.k];
        IPY.f = [IPY.f,abs(floSol(i).InPlane_y.freq)];
        Tilt.k = [Tilt.k,floSol(i).tilt.k];
        Tilt.f = [Tilt.f,abs(floSol(i).tilt.freq)];
        Trash.k = [Trash.k,floSol(i).trash.k];
        Trash.f = [Trash.f,abs(floSol(i).trash.freq)];
    end
    
    figure(1)
    hold on;
    MaxKf = max([OOP.k,IPX.k,IPY.k,Tilt.k,Trash.k]);
    flapLow = min(Trash.f);
    AllFreq = sort([OOP.f,IPX.f,IPY.f,Tilt.f,Trash.f]);
    [GapSize, idx] = max(AllFreq(2:end)-AllFreq(1:end-1));
    GapLow = AllFreq(idx); GapHi = AllFreq(idx+1);

    plot(OOP.k,OOP.f,'*r','DisplayName','OutOfPlane')
    plot(IPX.k,IPX.f,'o','DisplayName','InPlaneX','MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63])
    plot(IPY.k,IPY.f,'*b','DisplayName','InPlaneY')
    plot(Tilt.k,Tilt.f,'sk','DisplayName','Tilt')
    plot(Trash.k,Trash.f,'o','DisplayName','Falpping', 'MarkerEdgeColor','k','MarkerFaceColor','m')
    h = fill([0,MaxKf, MaxKf, 0],[GapLow, GapLow, GapHi, GapHi],[17 17 17]/255,'DisplayName','Gap');
    set(h,'facealpha',.5);
    axis([0 MaxKf 0 max(AllFreq)])
    legend
end