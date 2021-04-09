USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AD_ConsultaPedidosYSolepeds]    Script Date: 08/04/2021 01:28:15 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/03/2021>
-- Description:	<Consulta de los pedidos de los proveedores>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaPedidosYSolepeds] --1,''
	-- Add the parameters for the stored procedure here
	@Page INT,
	@Buscar NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (
						SELECT
							COUNT(1)
						FROM dbo.MM_Pedido AS P
						 JOIN dbo.TA_Operacion AS OP ON P.IdSolicitudPedido = OP.IdDocumento AND OP.IdTipoOperacion = 9 AND OP.IdEstatusOperacion <> 3
						LEFT JOIN dbo.MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido
						 JOIN dbo.MM_Pedidos AS PS ON P.IdPedido = PS.IdIdentificador AND PS.IdTipoPedido IN (2,4)
						WHERE (CAST(PS.IdPedido AS nvarchar) LIKE '%' + @Buscar + '%'
							OR CAST(P.IdSolicitudPedido AS nvarchar) LIKE '%' + @Buscar + '%')
						);


	SELECT *,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY P.IdPedido ORDER BY P.IdPedido DESC) AS R,
			SP.IdSolicitudPedido,
			PS.IdPedido AS IdPedidos,
			P.IdPedido,
			OP.NoVersion,
			OPE.RazonSocial AS Operadora,
			PRO.RazonSocial AS Proveedor,
			CON.NumeroContrato + ' - ' + AC.NombreAreaContractual AS Contrato,
			ES.Nombre AS EstatusPedido,
			SP.FechaAlta AS FechaSolped,
			P.CreadoEl AS FechaPedido,
			OP.IdOperacion,
			OPE.IdProveedor,
			ISNULL((SELECT TOP 1 TYC.Nombre 
					FROM TA_TerminosCondicionesOperacion TCO
					INNER JOIN TA_Operacion O 
						ON TCO.IdOperacion = O.IdOperacion 
					INNER JOIN MM_Pedido PIN 
						ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TC_TerminosYCondicionesDocV2 TYC 
						ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
					WHERE PIN.IdPedido = P.IdPedido),'Todavia no se asignan Terminos y Condiciones a este pedido.') AS NombreTC,
			ISNULL((SELECT TOP 1 TYC.IdTerminosYCondiciones
					FROM TA_TerminosCondicionesOperacion TCO
					INNER JOIN TA_Operacion O 
						ON TCO.IdOperacion = O.IdOperacion 
					INNER JOIN MM_Pedido PIN 
						ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TC_TerminosYCondicionesDocV2 TYC 
						ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
					WHERE PIN.IdPedido = P.IdPedido),0) AS IdTerminosYCondiciones,
			'' AS Documento,
			(ROW_NUMBER() OVER(ORDER BY P.IdPedido DESC) - 1) / @RecordsByPage AS _Page
		FROM dbo.MM_Pedido AS P
		 JOIN dbo.TA_Operacion AS OP ON P.IdSolicitudPedido = OP.IdDocumento AND OP.IdTipoOperacion = 9 AND OP.IdEstatusOperacion <> 3
		LEFT JOIN dbo.TA_Estatus AS ES ON OP.IdEstatusOperacion = ES.IdEstatus
		LEFT JOIN dbo.MM_SolicitudPedido AS SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN dbo.S_Proveedor AS OPE ON SP.IdProveedor = OPE.IdProveedor
		LEFT JOIN dbo.S_Proveedor AS PRO ON P.IdSubcontratista = PRO.IdProveedor
		LEFT JOIN Adinco.dbo.CO_Contrato AS CON ON SP.IdContrato = CON.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON CON.IdAreaContractual = AC.IdAreaContractual
		 JOIN dbo.MM_Pedidos AS PS ON P.IdPedido = PS.IdIdentificador AND PS.IdTipoPedido IN (2,4)
		--LEFT JOIN dbo.TA_TerminosCondicionesOperacion AS TCO ON OP.IdOperacion = TCO.IdOperacion
		--LEFT JOIN dbo.TC_TerminosYCondicionesDocV2 AS TC ON TCO.IdTerminosYCondiciones = TC.IdTerminosYCondiciones
		WHERE (CAST(PS.IdPedido AS nvarchar) LIKE '%' + @Buscar + '%'
			OR CAST(P.IdSolicitudPedido AS nvarchar) LIKE '%' + @Buscar + '%')
	) AS R
	WHERE --R.R = 1 AND
	R._Page = (@Page - 1)
	ORDER BY R.IdPedido DESC;

END
