-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/11/2019>
-- Description:	<consultar los materiales de una plantilla de una solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarMaterialesSolicitudPedido_Plantilla]
	-- Add the parameters for the stored procedure here
	@IdPlantillaSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		SPD.IdPlantillaSolicitudPedidoDetalle,--0
		SPD.IdMaterial,--1
		M.DescripcionCorta,--2
		M.DescripcionLarga,--3
		UN.Unidad AS NombreUnidad,--4
		UN.IdUnidad,--5
		SPD.Cantidad,--6
		SPD.Observaciones,--7
		SPD.IdDomicilioEntrega,--8
		SPD.IdCentroCosto,--9
		SPD.IdInstalacion,--10
		SPD.IdLineaPresupuesto--11
	FROM dbo.MM_Plantilla_SolicitudPedidoDetalle AS SPD
		LEFT JOIN dbo.MM_Material AS M ON M.IdMaterial = SPD.IdMaterial
		LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = SPD.IdUnidad
	WHERE SPD.IdPlantillaSolicitudPedido = @IdPlantillaSolicitudPedido
		AND SPD.Activo = 1;


END
