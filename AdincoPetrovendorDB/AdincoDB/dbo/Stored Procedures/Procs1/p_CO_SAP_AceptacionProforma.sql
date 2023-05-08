CREATE PROCEDURE [dbo].[p_CO_SAP_AceptacionProforma]
@PoNumber varchar(20),
@Reference varchar(20),
@IdUsuario int,
@IdSAPSES int,
@error varchar(200) out,
@IdSAPProf int out,
@IsSesGR int
as
begin
--SES 1
--GR 2
	DECLARE @IdSAPProforma int,
			@IdSAPPO       int;
	
	--set @IdSAPProf = (0);
	set @error = ('no');

	IF EXISTS (select 1 from 
		CO_SAPProforma as p
		join CO_SAPPOData as po on p.IdSAPPO = po.IdSAPData
		where SAPPONumber = @PoNumber and Reference = @Reference and IdEstatus = 1)
		BEGIN
			select
				@IdSAPProforma = p.IdSAPProforma,
				@IdSAPPO	   = p.IdSAPPO
				from 
				CO_SAPProforma as p
									join CO_SAPPOData as po on p.IdSAPPO = po.IdSAPData
									where SAPPONumber = @PoNumber and Reference = @Reference
			set @IdSAPProf = (@IdSAPProforma);
			--SELECT @IdSAPProforma , @IdSAPPO       
			BEGIN TRY
				BEGIN TRANSACTION
				IF	@IsSesGR = 1 --SES
				BEGIN
			------------- ACTUALIZACIÓN DE LA PROFORMA -----------
			------------------------------------------------------
							UPDATE CO_SAPProforma
							set IdEstatus = 2
							,ModificadoEl = GetDate()
							,ModificadoPor = @IdUsuario
							,ComentarioInterno = 'Aprobación Proforma desde Importación ADINCO'
							,IdSAPSES = @IdSAPSES
							where IdSAPProforma = @IdSAPProforma
			------------- INSERCION EN LA BITACORA -----------
			------------------------------------------------------
						INSERT INTO CO_SAPProformaBitacora(
							IdSAPProforma,IdSAPPO,Descripcion,
							Reference,IdEstatus,ComentarioInterno,
							CreadoEl,CreadoPor,IdSAPSES)
						VALUES 
							(@IdSAPProforma,@IdSAPPO,'Aprobación Proforma desde Importación ADINCO',
							@Reference,2,'Aprobación Proforma desde Importación ADINCO',
							GetDate(), @IdUsuario,@IdSAPSES)
				END
				IF	@IsSesGR = 2 --GR
				BEGIN
			------------- ACTUALIZACIÓN DE LA PROFORMA -----------
			------------------------------------------------------
							UPDATE CO_SAPProforma
							set IdEstatus = 2
							,ModificadoEl = GetDate()
							,ModificadoPor = @IdUsuario
							,ComentarioInterno = 'Aprobación Proforma desde Importación ADINCO'
							,IdSAPGR = @IdSAPSES
							where IdSAPProforma = @IdSAPProforma
			------------- INSERCION EN LA BITACORA -----------
			------------------------------------------------------
						INSERT INTO CO_SAPProformaBitacora(
							IdSAPProforma,IdSAPPO,Descripcion,
							Reference,IdEstatus,ComentarioInterno,
							CreadoEl,CreadoPor,IdSAPGR)
						VALUES 
							(@IdSAPProforma,@IdSAPPO,'Aprobación Proforma desde Importación ADINCO',
							@Reference,2,'Aprobación Proforma desde Importación ADINCO // gr',
							GetDate(), @IdUsuario,@IdSAPSES)
				END
				SELECT 'MODIFICADO' AS MENSAJE
				COMMIT
			END TRY
			BEGIN CATCH    
				ROLLBACK
			END CATCH
		END
		ELSE
		BEGIN
			SELECT 'NO MODIFICADO' AS MENSAJE
		END
end
