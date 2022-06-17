--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE Petrovendor
GO
DROP PROCEDURE IF EXISTS MPY_MM_SP_GuardarGasto
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26-06-2018>
-- Description:	<Se guarda el gasto de una factura>
-- =============================================
-- Author:		<Luis David>
-- Create date: <15/06/2022>
-- Description:	<Se valida si la factura es de Murphy para así agregar la linea presupuesto 241612 (Issue #1865 Petrovendor)>
-- =============================================
--  [MPY_MM_SP_GuardarGasto] 21847,null,10039,2,null
CREATE procedure [dbo].[MPY_MM_SP_GuardarGasto]
	@IdFactura INT,
	@IdAceptacionPedido int = NULL,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

	declare @IdLineapresupuesto int,
			@IdPrograma int,
			@IdInstalacion int,
			@RFC varchar(100);

	select	@IdLineapresupuesto = pm.IdLineapresupuestoMes ,
			@IdPrograma = p.IdProgramaActividad,
			@IdInstalacion = pm.IdInstalacion
	from Adinco..CO_LineaPresupuestoMes pm
	inner join Adinco..CO_Presupuesto p on p.IdPresupuesto = pm.IdPresupuesto
	inner join Adinco..[CO_AnioContractual] ac on p.IdAnioContractual = ac.IdAnioContractual 
	inner join FI_Factura f on ac.IdContrato = f.IdContrato and
							datepart(yy,pm.AC_PRESUP_MES) = datepart(yy,f.Fecha)
	where f.IdContrato = @IdContrato
	
	SET @RFC = (
	SELECT TOP 1 receptor 
	FROM FI_Factura 
	WHERE IdFactura = @IdFactura)

	IF @RFC = 'MSU150922EYA'
	BEGIN
		SET @IdLineapresupuesto = (241612)
	END
	BEGIN TRY  

		begin tran
		--Insertar gastos en Petrovendor
			INSERT INTO dbo.CO_Registro
			(
				IdFactura,
				MontoRegistro,
				InicioEjecucion,
				FinEjecucion,
				Comentarios,
				MesPresentacion,
				IdUsuarioCreadoPor,
				FecMovto,
				IdInstalacion,
				CreadoPor,
				IdCatalogoCuentasSH,
				CentroCostos,
				CuentaContable,
				IdLineaPresupuestoMes,
				Poliza,
				CostosAtribuiblesAdministracion
			)
			select f.IdFactura,
				fd.Importe,
				NULL,
				f.Fecha,
				fd.Descripcion,
				DATEADD(MONTH, DATEDIFF(MONTH, 0, f.Fecha), 0),
				@IdUsuario,
				GETDATE(),
				NULL,
				@IdUsuario,
				10000,
				9,
				2,	
				@IdLineapresupuesto,
				NULL,
				0
			from FI_Factura f
			inner join [dbo].[FI_CFDIConcepto] fd on f.IdFactura = fd.IdFactura
			where f.IdFactura = @IdFactura
		--Insertar gastos en Adinco
			INSERT INTO Adinco..CO_Registro
			(
				/*IdRegistro,*/				IdPrograma,				IdFactura,			MontoRegistro,
				InicioEjecucion,		FinEjecucion,			Comentarios,		MesPresentacion,
				IdEstado,				IdUsuarioCreadoPor,		IdUsuarioModPor,	FecMovto,
				IdInstalacion,			CreadoPor,				Fila,				IdPedimentoComprobante,
				CvTipoDocFacturacion,	IdCatalogoCuentasSH,	Poliza,				IsEditable,
				CostosAtribuiblesAdministracion,EstadoDePresentacion,MesCertificadoCIEP,IdGastoRubro,
				PCN,					Importado,				BitPCNP,			IdCBSISH,
				IdAceptacionPedidoDetalle,MesGasto				
			)
			select						@IdLineapresupuesto,			f2.IdFactura,				fd.Importe,
				NULL,					f.Fecha,				fd.Descripcion,				DATEADD(MONTH, DATEDIFF(MONTH, 0, f.Fecha), 0),
				10004,					@IdUsuario,				null,				GETDATE(),
				@IdInstalacion,			@IdUsuario,				NULL,				NULL,
				CvTipoDocFacturacion=1,	10000,					null,				1,
				CostosAtribuiblesAdministracion = 0,EstadoDePresentacion = 0, MesCertificadoCIEP = null,IdGastoRubro = 3,
				PCN = 0,				NULL,					NULL,				NULL,
				NULL,					f.Fecha			
			from FI_Factura f
			inner join [dbo].[FI_CFDIConcepto] fd on f.IdFactura = fd.IdFactura
			INNER JOIN Adinco..FI_factura f2 on f.UUID collate Modern_Spanish_CI_AS = f2.UUID collate Modern_Spanish_CI_AS
			where f.IdFactura = @IdFactura

			
			insert into [dbo].[CO_RelacionRegistroAdinco](
				IdRegistroPetrovendor,IdRegistroAdinco
			)
			select rp.IdRegistro,ra.IdRegistro
			from CO_Registro rp 
			inner join FI_factura  f on rp.IdFactura = f.IdFactura
			inner join [FI_CFDIConcepto] fd on rp.IdFactura = fd.IdFactura
			inner join Adinco..FI_factura fa on f.UUID COLLATE Modern_Spanish_CI_AS = fa.UUID COLLATE Modern_Spanish_CI_AS
			inner join Adinco..CO_Registro ra on fa.IdFactura = ra.IdFactura and
											rp.Comentarios COLLATE Modern_Spanish_CI_AS = ra.Comentarios COLLATE Modern_Spanish_CI_AS
			where rp.IdFactura = @IDFACTURA and			
			convert(varchar,rp.FecMovto,112) = convert(varchar,getdate(),112) and
			not exists (
				select 1
				from [CO_RelacionRegistroAdinco]
				where IdRegistroPetrovendor = rp.IdRegistro 
			) and not exists(
				select 1
				from [CO_RelacionRegistroAdinco]
				where IdRegistroAdinco = ra.IdRegistro 
			) 
			GROUP BY rp.IdRegistro,ra.IdRegistro 
			

			

			commit tran
	END TRY  
	BEGIN CATCH  
		rollback tran

		RAISERROR (15600,-1,-1, 'Ocurrió un error al generar los gastos'); 
		
	END CATCH  

	
 
END
