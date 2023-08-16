IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_CO_SAP_ImportBitacora_GRD'
)
    DROP PROCEDURE p_CO_SAP_ImportBitacora_GRD;
GO
CREATE PROCEDURE [dbo].[p_CO_SAP_ImportBitacora_GRD] 
@pIdContrato INT,
@Desde datetime=null,
@Hasta datetime=null
AS    
     BEGIN       
         SET NOCOUNT ON;
			SELECT CO_SAP_ImportBitacora.Id,
				   CO_SAP_ImportBitacora.IdContrato,
				   CO_SAP_ImportBitacora.Inicio,
				   CO_SAP_ImportBitacora.Fin,
				   CO_SAP_ImportBitacora.TieneError,
				   CO_SAP_ImportBitacora.IdNotificacion,
				   CO_SAP_ImportBitacora.CreadoEl,
				   CO_SAP_ImportBitacora.CreadoPor,
				   ISNULL(CO_SAP_ImportBitacora.NotificacionEnviada, 0) NotificacionEnviada,
				   CO_SAP_ImportBitacora_Detalle.Id,
				   CO_SAP_ImportBitacora_Detalle.IdImportBitacora,
				   CO_SAP_ImportBitacora_Detalle.NombreArchivo,
				   CO_SAP_ImportBitacora_Detalle.Error,
				   TieneError2 = ISNULL(CO_SAP_ImportBitacora_Detalle.TieneError, 0),
				   ISNULL(AplicacionEjecuto, '') AplicacionEjecuto
			FROM CO_SAP_ImportBitacora  (NOLOCK)
				LEFT JOIN CO_SAP_ImportBitacora_Detalle  (NOLOCK)
					ON CO_SAP_ImportBitacora_Detalle.IdImportBitacora = CO_SAP_ImportBitacora.Id
			WHERE CO_SAP_ImportBitacora.IdContrato = @pIdContrato
				AND (CO_SAP_ImportBitacora.CreadoEl between dateadd(day, -1, @Desde) and dateadd(day, 1, @Hasta))
				OR
					(@Desde is null AND @Hasta is null)
			ORDER BY CO_SAP_ImportBitacora.CreadoEl DESC

END;