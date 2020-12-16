function Q = Q_ThinPlate(model, modeIndex, sweepIndex)
    import com.comsol.model.*
    import com.comsol.model.util.*
    if nargin < 3
        E = mphglobal(model, 'Si3N4.def.E', 'dataset', 'dset1', ...
             'solnum', 1);
        nu = mphglobal(model, 'Si3N4.def.nu', 'dataset', 'dset1', ...
             'solnum', 1);
        temp = mphint2(model,'(abs(solid.eXX)+abs(solid.eYY))^2-2*(1-Si3N4.def.nu)*(abs(solid.eXX)*abs(solid.eYY)-abs(solid.eXY)^2/4)',...
            'volume', 'dataset', 'dset1', 'intvolume','on', ...
            'solnum', modeIndex);

        deltaU = pi*imag(E)/(1-nu^2)*temp;
        U = 0.5*real(E)/(1-nu^2)*temp;
        prestressedPart = mphint2(model,'solid.Sil11*abs(solid.eXX)+solid.Sil22*abs(solid.eYY)',...
            'volume', 'dataset', 'dset1', 'intvolume','on',  ...
            'solnum', modeIndex);
        U = U + prestressedPart;
    elseif nargin == 3
        E = mphglobal(model, 'Si3N4.def.E', 'dataset', 'dset3', ...
            'outsolnum', 1, 'solnum', 1);
        nu = mphglobal(model, 'Si3N4.def.nu', 'dataset', 'dset3', ...
            'outsolnum', 1, 'solnum', 1);
        temp = mphint2(model,'(solid.eXX+solid.eYY)^2-2*(1-Si3N4.def.nu)*(solid.eXX*solid.eYY-solid.eXY^2/4)',...
            'volume', 'dataset', 'dset3', 'intvolume','on', 'outsolnum', sweepIndex, ...
            'solnum', modeIndex);

        deltaU = pi*imag(E)/(1-nu^2)*temp;
        U = 0.5*real(E)/(1-nu^2)*temp;
        prestressedPart = mphint2(model,'solid.Sil11*solid.eXX+solid.Sil22*solid.eYY',...
            'volume', 'dataset', 'dset3', 'intvolume','on', 'outsolnum', sweepIndex, ...
            'solnum', modeIndex);
        U = U + prestressedPart;
    end
    
    Q = 2*pi*U/deltaU;
end