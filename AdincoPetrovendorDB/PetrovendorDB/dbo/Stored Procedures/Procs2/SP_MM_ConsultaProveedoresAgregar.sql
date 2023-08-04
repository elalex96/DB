USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaProveedoresAgregar'
)
    DROP PROCEDURE SP_MM_ConsultaProveedoresAgregar;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <06/02/2020>  
-- Description: <consulta de proveedores para el agredado en la peticion oferta ya enviada>  
-- ============================================= 
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaProveedoresAgregar]  
 -- Add the parameters for the stored procedure here  
 @IdProveedor INT,  
 @Buscar NVARCHAR(200),  
 @Page INT,  
 @IdSolicitudPedido INT,  
 /*--------------------  
 parametros contrato  
 --------------------*/  
 @IdContrato    INT = NULL,  
 @IdUsuario     INT = NULL,  
 @FechaRegistro DATETIME = NULL  
   /*--------------------  
   --------------------*/  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
    -- Insert statements for procedure here
	DECLARE @RecordsByPage INT;
	DECLARE @AllRecords INT;

	--TABLA PARA GUARDAR PROVEEDOR YA SELECCIONADOS A LA PETICION OFERTA  
	CREATE TABLE #PROVEEDORESSELECCIONADOS  
	(  
	IdProveedor INT  
	);  

	CREATE TABLE #CO_CONTRATISTA(
		RFC NVARCHAR(100)
	);

	CREATE TABLE #LISTA_PROVEEDORES_TOTAL(
		IdProveedor INT,
		RazonSocial NVARCHAR(1000),
		IsBlackList BIT
	);

 --SE AGREGAN LOS PROVEEDORES SELECCIONADOS A LA PETICION OFERTA  
 INSERT INTO #PROVEEDORESSELECCIONADOS  
 SELECT  
  PO.IdSubcontratista  
 FROM dbo.MM_PeticionOferta AS PO (NOLOCK)
 WHERE PO.IdSolicitudPedido = @IdSolicitudPedido; 
 
 INSERT INTO #CO_CONTRATISTA (RFC)
	SELECT RFC 
	FROM Adinco..CO_Contratista (NOLOCK)
	WHERE RFC IS NOT NULL 
		AND RFC != 'TEN150921DA7'
		AND RFC != 'PMS090112TB0'--PICO México Servicios Petroleros S. DE R.L. DE C.V. 

 INSERT INTO #LISTA_PROVEEDORES_TOTAL
	SELECT
		P.IdProveedor,
		P.RazonSocial + ' ' + ISNULL(P.RegimenCapital,'') AS RazonSocial,
		CASE
			WHEN LN.RFC IS NULL THEN 0
			ELSE 1
		END AS IsBlackList
	FROM dbo.S_Proveedor AS P WITH (NOLOCK)
		LEFT JOIN Adinco.dbo.ListaNegra AS LN WITH (NOLOCK)
			ON P.RFC COLLATE Modern_Spanish_CI_AS = LN.RFC COLLATE Modern_Spanish_CI_AS
	WHERE P.Activo = 1
		AND P.IdProveedor <> @IdProveedor
		AND ISNULL(P.IsEliminado,0) = 0 
		AND P.IdProveedor NOT IN (SELECT IdProveedor FROM #PROVEEDORESSELECCIONADOS)
		AND P.RFC COLLATE Modern_Spanish_CI_AS NOT IN (SELECT RFC FROM #CO_CONTRATISTA)
		AND (P.RazonSocial LIKE '%' + @Buscar + '%' OR P.RFC LIKE '%' + @Buscar + '%');

   
 SET @RecordsByPage = 16;  
 SET @AllRecords = (SELECT COUNT(IdProveedor) FROM #LISTA_PROVEEDORES_TOTAL);
  
 SELECT 
		*,
		@AllRecords AS Records,
		@RecordsByPage AS RecordByPage
	FROM 
	(
		SELECT 
			ROW_NUMBER() OVER(PARTITION BY LP.IdProveedor ORDER BY LP.RazonSocial ASC) AS R,
			LP.IdProveedor,
			LP.RazonSocial,
			dbo.FN_MM_ObtenerCorreoProveedor(LP.IdProveedor) AS CorreoEmpresa,
			dbo.ObtenerEstrellasModificado(LP.IdProveedor) AS Estrellas,
			LP.IsBlackList,
			IMP.ImagenProveedorThumb AS ImagenProveedor,
			dbo.FN_PedidosSubContratista(LP.IdProveedor) AS PedidosRealizados,
			dbo.FN_AntiguedadSubContratista(LP.IdProveedor) AS AntiguedadSubContratista,
			dbo.FN_CantidadClientesSubContratista(LP.IdProveedor) AS CantidadClientes,
			(ROW_NUMBER() OVER(ORDER BY RazonSocial DESC) - 1)/ @RecordsByPage _Page
		FROM #LISTA_PROVEEDORES_TOTAL AS LP
		LEFT JOIN dbo.S_ImagenPerfil AS IMP WITH (NOLOCK)
				ON LP.IdProveedor = IMP.IdProveedor
	)
	AS R WHERE R.R = 1
	AND R._Page = (@Page - 1)
	ORDER BY R.RazonSocial; 
  
END