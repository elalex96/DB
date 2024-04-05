use petrovendor
go
drop proc if exists SP_PR_MM_ConsultaSolicitudPedidoDetalleReporte
go
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
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
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

	CREATE TABLE #tmpSubActividad (
		IdLineaPresupuestoMes INT,
		SubActividad NVARCHAR(MAX)
	);


	INSERT INTO #tmpSubActividad (IdLineaPresupuestoMes, SubActividad)
	SELECT lp.IdLineaPresupuestoMes, dbo.Fn_RetornarMesProgramadoActividadConcat(IdLineaPresupuestoMes)
	FROM MM_SolicitudPedido AS SP (NOLOCK)
	INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
		ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido 
	LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
		ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle
	LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp (NOLOCK)
		ON SPDLP.IdLineaPresupuesto = lp.IdLineaPresupuestoMes
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
		AND SP.IdProveedor = @IdProveedor;

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
		 sv.SubActividad AS SubActividad
		FROM MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
		INNER JOIN MM_SolicitudPedido AS SP (NOLOCK)
			ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido 
				AND SP.IdSolicitudPedido = @IdSolicitudPedido 
				AND SP.IdProveedor=@IdProveedor
		LEFT JOIN MM_Material AS MM (NOLOCK)
			ON SPD.IdMaterial = MM.IdMaterial		
		LEFT JOIN PV_MM_MaterialUnidad AS U (NOLOCK)
			ON SPD.IdUnidad = U.IdUnidad
		LEFT JOIN DG_Domicilio AS D (NOLOCK)
			ON SPD.IdDomicilioEntrega = D.IdDomicilio		
		LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
			ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle
		LEFT JOIN CC_CentroCosto AS CC (NOLOCK)
			ON SPDLP.IdCentroCosto = CC.IdCentroCosto
		LEFT JOIN Adinco.dbo.CO_Instalacion AS i (NOLOCK)
			ON SPDLP.IdInstalacion = i.IdInstalacion
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp (NOLOCK)
			ON SPDLP.IdLineaPresupuesto = lp.IdLineaPresupuestoMes 
		LEFT OUTER JOIN Adinco.dbo.CO_TareaPetrolera AS t (NOLOCK)
			ON lp.IdTareaPetrolera = t.IdTareaPetrolera
		LEFT JOIN #tmpSubActividad AS sv ON SPDLP.IdLineaPresupuesto = sv.IdLineaPresupuestoMes

     END;
