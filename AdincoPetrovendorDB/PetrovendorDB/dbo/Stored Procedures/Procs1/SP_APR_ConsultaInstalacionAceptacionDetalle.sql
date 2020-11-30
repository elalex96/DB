-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/04/2020>
-- Description:	<Consulta del centro de costo por aceptacion detalle>
-- =============================================
CREATE PROCEDURE [dbo].[SP_APR_ConsultaInstalacionAceptacionDetalle]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedidoDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDCONTRATO INT;
    -- Insert statements for procedure here

	SET @IDCONTRATO = ( SELECT TOP 1
							SP.IdContrato
						FROM dbo.MM_AceptacionPedidoDetalle AS APD
							LEFT JOIN dbo.MM_PedidoDetalle AS PD
								ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
							LEFT JOIN dbo.MM_PeticionOfertaDetalle AS POD
								ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
							LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
								ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
							LEFT JOIN dbo.MM_SolicitudPedido AS SP
								ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
						WHERE APD.IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle
						GROUP BY SP.IdContrato);

	SELECT
        I.IdInstalacion, 
		I.NombreInstalacion
    FROM Adinco.dbo.CO_Instalacion AS I
		INNER JOIN Adinco.dbo.CO_Contrato AS C
			ON C.IdAreaContractual = I.IdAreaContractual
    WHERE C.IdContrato = @IDCONTRATO
          AND ISNULL(I.EsBolsa, 0) = 0
		  AND I.Activo = 1;

END
