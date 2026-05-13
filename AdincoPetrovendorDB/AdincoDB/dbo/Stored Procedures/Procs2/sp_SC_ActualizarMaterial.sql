USE adinco
GO
DROP PROC IF EXISTS sp_SC_ActualizarMaterial
GO
-- Modificado por: David de la cruz
-- Modificado el: 19/Marzo/2025
-- Descripción: Se elimina @IdUsuarioAdinco ya que no siempre coincide el nombre de petrovendor con el nombre de adinco y no coincide el IdUsuario, se cambia las estructuras de transacciones y se elimina la relación de la columna consepto
CREATE PROC sp_SC_ActualizarMaterial
@pIdSCMaterial INT,
@pIdSubContrato INT,
@pConcepto VARCHAR(30),
@pIdMaestro INT,
@pIdUnidad INT,
@pIdServicio INT,
@pCantidad DECIMAL(14,2),
@pPrecioUnitario MONEY,
@pImporte MONEY,
@pDescripcion VARCHAR(510),
@pDescripcionCorta VARCHAR(250),
@pModificadoPor INT,
@pAprobarConvenioOT BIT,
@pIdOTSolicitud INT
AS
BEGIN
    DECLARE @IdSCBitacora INT, @pError VARCHAR(250),@ErrorMsg varchar(250);
    
    BEGIN TRY
        BEGIN TRAN;
        
		drop table if exists #tmpCantidades
		create table  #tmpCantidades (
        IdSubcontrato int,
        IdSCMaterial int,
		IdOTSM int,
		CantidadSC float,
		CantidadOT float
    )
		insert into #tmpCantidades
		select 
                sMat.idSubcontrato,
                sMat.IdSCMaterial,  
				otMat2.IdOTSolicitudMATERIAL,
				CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(otMat2.Cantidad)
        from  SC_Materiales sMat 
        inner join [OT_SolicitudMaterial] otMat2 
		on SmAT.IdSCMaterial = otMat2.IdSCMaterial
        inner join OT_Solicitud ot2 
		on otMat2.IdOTSolicitud  = ot2.IdOTSolicitud
		and ot2.IdOTEstatus NOT in (7,8,12) 
		and isnull(ot2.IsActivo,0) = 1			
		
		
       where sMat.IdSCMaterial = @pIdSCMaterial
	    group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial,
				otMat2.IdOTSolicitudMATERIAL

		insert into #tmpCantidades 
		select 
                sMat.idSubcontrato,
                sMat.IdSCMaterial,  
				SPC.IdOTSolicitudMATERIAL,
				CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(spc.Captura)
        from  SC_Materiales sMat 
        inner join [OT_SolicitudMaterial] otMat2 
		on SmAT.IdSCMaterial  = otMat2.IdSCMaterial
        inner join OT_Solicitud ot2 
		on otMat2.IdOTSolicitud = ot2.IdOTSolicitud
		and ot2.IdOTEstatus  in (12) 
		and isnull(ot2.IsActivo,0) = 1	 
		and ot2.IsEliminado = 0		
		inner join OT_SolicitudProgramaCaptura spc 
		on spc.VoBoContratista = 1 
		and otMat2.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial
		where  sMat.IdSCMaterial = @pIdSCMaterial
        group by 
		sMat.idSubcontrato,
        sMat.IdSCMaterial,
		SPC.IdOTSolicitudMATERIAL


		/************Validar que no se intente insertar mas de una vez el servicio para el subcontrato******************/
	if (
		select count(distinct IdSCMaterial)
		from sc_materiales
		where @pIdSubContrato = IdSubContrato and
		IdServicio = @pIdServicio and
		IdMaestro = @pidMaestro  and
		IdSCMaterial <> @pIdSCMaterial
		)
		>0
	begin
		SET @ErrorMsg = 'No se puede ingresar un servicio maestro duplicado';
		THROW 50000, @ErrorMsg, 1;
	end
        if(
		SELECT SUM(CantidadOT)
		from #tmpCantidades
		where IdSCMaterial = @pIdSCMaterial
	) > @pCantidad
	begin
		SET @ErrorMsg = 'No se puede capturar menos cantidad de la que ya está asignada a OTs';
		THROW 50000, @ErrorMsg, 1;
		--THROW (15600,-1,-1, 'No se puede captura menos cantidad de la que ya está asignada a OTs');
	end
	/*******************INSERTAR BITACORA****************************************/
	select @IdSCBitacora = isnull(max(IdSCBitacora),0) + 1
	from [SC_MaterialesBitacora]

	insert into [SC_MaterialesBitacora](
		IdSCBitacora,IdSCMaterial,CantidadRespaldo,FechaRespaldo,ModificadoPor
	)	
	select 	@IdSCBitacora,@pIdSCMaterial,Cantidad,getdate(), @pModificadoPor
	from sc_materiales
	where  IdSCMaterial =@pIdSCMaterial

	update sc_materiales
		set concepto = @pConcepto,				
			IdUnidad = @pIdUnidad,
			Cantidad = @pCantidad,
			PrecioUnitario = @pPrecioUnitario,
			Importe = @pImporte,
			Descripcion = @pDescripcion,
			DescripcionCorta = @pDescripcionCorta,		 	
			ModificadoPor = @pModificadoPor,
			ModificadoEl = getdate(),
			IdServicio = case when @pIdServicio = 0 then null else @pIdServicio end
	where IdSCMaterial =@pIdSCMaterial

        /********** APROBAR EL CONVENIO ************/
        IF @pAprobarConvenioOT = 1
        BEGIN
            EXEC p_OT_AprobarConvenios @pIdSubContrato, @pModificadoPor, @pError OUT;
			select @pError as 'error'
            IF @pError <> ''
            BEGIN
				set @ErrorMsg = @pError;
                THROW 50000, @ErrorMsg, 1;
            END
        END
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH;
END
