-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-07-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 09-01-2018
-- Description:	MODIFIQUE LA FECHA LIMITE DE COTIZACIÓN y AGREGUE FORMATO A FECHA
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_TablaComparativaCabecera]   
	-- Add the parameters for the stored procedure here
@IdSolicitudPedido INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT TOP 1 SP.IdSolicitudPedido,
                TSP.TipoSolicitudPedido,
                CASE SP.AdjudicableParcialmente
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Adjudicable,
                CASE SP.VisitaRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS VisitaRequerida,
                CASE SP.JuntaAclaracionesRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS JuntaAclaracionesRequerida,
                CASE SP.UnaSolaEntregaRequerida
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS EntregaUnica,
                CASE SP.UnaSolaEntregaRequerida
                    WHEN 0
                    THEN 'SI'
                    ELSE 'NO'
                END AS EntregaParcial,
                CASE SP.Fianza
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Fianza,
                CASE SP.Controlados
                    WHEN 1
                    THEN 'SI'
                    ELSE 'NO'
                END AS Controlados,
                PSP.Prioridad,
                U.Nombre AS Solicitante,
                TAO.IdOperacion,
                ISNULL(SP.PeticionEnviada, 'false') AS PeticionEnviada,
                TiOp.NombreOperacion,
                CONCAT(Pr.RazonSocial COLLATE DATABASE_DEFAULT, ' ', Pr.RegimenCapital COLLATE DATABASE_DEFAULT, ' ', Pr.Municipio COLLATE DATABASE_DEFAULT, ' ', Pr.Entidad COLLATE DATABASE_DEFAULT) AS Proveedor,
                TAO.FechaRegistro AS FRegistroCabecera,
                TAO.Descripcion AS DescCabecera,
                TAO.FechaFinalizacion AS FLimiteCabecera,
                CONCAT(FORMAT(SP.FechaEntregaRequerida,'dd/MM/yyyy'), CASE WHEN SP.FechaEntregaFinRequerida IS NOT NULL THEN ' - ' + FORMAT( SP.FechaEntregaFinRequerida,'dd/MM/yyyy') END) AS FEntregaCabezera,
				TAO.IdTipoOperacion,
				SP.IdEstatusEliminado 
         FROM MM_SolicitudPedido AS SP
              LEFT JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
              LEFT JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido
              LEFT JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
              LEFT JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
              LEFT JOIN S_Usuario AS U ON U.IdUsuario = TAO.IdAsignador
              LEFT JOIN TA_TipoOperacion AS TiOp ON TiOp.IdTipoOperacion = TAO.IdTipoOperacion
              LEFT JOIN CC_CentroCosto AS CC ON CC.IdCentroCosto = SP.IdCentroCosto
              LEFT JOIN MM_TerminoComercio AS TC ON TC.IdTerminoComercio = SP.IdTerminoInternacionales
              LEFT JOIN MM_TipoGastos AS TG ON TG.IdTipoGasto = SP.IdTipoGasto
              LEFT JOIN S_Proveedor AS Pr ON SP.IdProveedor = Pr.IdProveedor
              LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = TAO.IdVigencia
         WHERE TAO.IdTipoOperacion = 6
               AND SP.IdSolicitudPedido = @IdSolicitudPedido

			
     END;

