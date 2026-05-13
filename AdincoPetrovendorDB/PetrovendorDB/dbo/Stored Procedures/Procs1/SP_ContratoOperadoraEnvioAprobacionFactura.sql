USE [Petrovendor]
GO
DROP PROC IF EXISTS [SP_ContratoOperadoraEnvioAprobacionFactura]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <08/10/19>
-- Description:	<Consulta el nombre del contrato de la operadora de la aceptación de pedido>
-- Daniel AC se agrega validación de datos nulls 28/01/2026
-- =============================================
CREATE PROCEDURE SP_ContratoOperadoraEnvioAprobacionFactura
@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT
		C.IdContrato AS IdContratoOperadora,
		CONCAT(ISNULL(C.NumeroContrato,''), ' - ',ISNULL(AC.NombreAreaContractual,'')) AS NombreContrato
		FROM MM_AceptacionPedido AP (NOLOCK)
		JOIN MM_Pedido P (NOLOCK)
			ON AP.IdPedido =  P.IdPedido 
		LEFT JOIN Adinco..CO_Contrato C  (NOLOCK)
			ON P.IdContrato = C.IdContrato 
		LEFT JOIN Adinco..CO_AreaContractual AC (NOLOCK)
			ON C.IdAreaContractual = AC.IdAreaContractual 
		WHERE AP.IdAceptacionPedido = @IdAceptacionPedido

END
