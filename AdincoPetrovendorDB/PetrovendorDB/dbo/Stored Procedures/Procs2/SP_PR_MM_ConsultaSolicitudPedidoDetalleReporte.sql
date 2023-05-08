-- =============================================
-- Author:		Daniel AC
-- Update date: 07-11-2018
-- Description: se cambia el retorno de la subatividad a una concatenacion de campos
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================

CREATE PROCEDURE [dbo].[SP_PR_MM_ConsultaSolicitudPedidoDetalleReporte]
	-- Add the parameters for the stored procedure here
@IdSolicitudPedido INT,
@IdProveedor INT,
@IdContrato INT,
@IdUsuario INT, 
@FechaRegistro DATETIME

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

		 SELECT 
		 ROW_NUMBER() OVER(ORDER BY  MM.DescripcionCorta ASC)  AS IdPartida,
		 sp.IdSolicitudPedido,
		 SPD.IdSolicitudPedidoDetalle,		 
		 CONCAT(' Descripción: ', MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END) AS DescripcionCorta,
		 MM.IdMaterial AS IdMaterial,
		 SPD.Cantidad, 		
		 SPD.Observaciones, 
		 U.Unidad AS NombreUnidad,
		 CONCAT(ISNULL(D.Calle,''),
		 ' ',ISNULL(D.NoExterior,''),' ',
		 ISNULL(D.NoInterior,''),' ',
		 ISNULL(D.Colonia,''),' ',
		 ISNULL(D.Municipio,''),' ',
		 ISNULL(D.Estado,''),' ',
		 ISNULL(D.Pais,''),' ',
		 ISNULL(D.CodigoPostal,'')) AS DireccionEntrega,
		 CC.CentroCosto,
		 i.NombreInstalacion, 
		 dbo.Fn_RetornarMesProgramadoActividadConcat(lp.IdLineaPresupuestoMes) AS SubActividad 
		FROM MM_SolicitudPedidoDetalle AS SPD
		INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido=SPD.IdSolicitudPedido
		LEFT JOIN MM_Material AS MM ON MM.IdMaterial = SPD.IdMaterial		
		LEFT JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = SPD.IdUnidad
		LEFT JOIN DG_Domicilio AS D ON D.IdDomicilio=SPD.IdDomicilioEntrega		
		LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		LEFT JOIN CC_CentroCosto AS CC ON CC.IdCentroCosto = SPDLP.IdCentroCosto
		LEFT JOIN Adinco.dbo.CO_Instalacion AS i ON i.IdInstalacion = SPDLP.IdInstalacion
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp ON lp.IdLineaPresupuestoMes = SPDLP.IdLineaPresupuesto
		LEFT OUTER JOIN Adinco.dbo.CO_TareaPetrolera AS t ON t.IdTareaPetrolera = lp.IdTareaPetrolera
		WHERE SP.IdSolicitudPedido = @IdSolicitudPedido AND SP.IdProveedor=@IdProveedor


     END;

