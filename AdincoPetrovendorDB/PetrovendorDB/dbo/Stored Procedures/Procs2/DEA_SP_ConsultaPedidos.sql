USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_ConsultaPedidos'
)
    DROP PROCEDURE DEA_SP_ConsultaPedidos;
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidosCliente]    Script Date: 05/07/2022 02:12:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Update: 11-07-2022
-- Description: Consulta lista de pedidos por contrato
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaPedidos] 
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,    
    @IdUsuario INT,
	@IdContrato INT,
	@PageSize INT,              --Tamaño página
    @PageNumber INT,            --Número de página   
    @Buscar NVARCHAR(MAX) = '', --Filtro por campo   
	@Order NVARCHAR(100),
    @OrderType NVARCHAR(100)
	
AS
BEGIN
    SET NOCOUNT ON;
	declare 
	@PageCount INT=0,         --Retorno de cantidad de páginas
    @RecordCnt INT =0         --Retorno de cantidad de resultados 

	--VALIDACIÓN DE PRECONDICIONES
    SET @PageCount = 0;
    IF @PageSize < 1
       OR @PageNumber < 1
    BEGIN
        SET @PageSize = 10;
        SET @PageNumber = 1;
    END;
	SET @Buscar =LTRIM(RTRIM(@Buscar))

	--Ajuste de cantidad de páginas
    SET @RecordCnt = 0; 
	   
	SELECT @RecordCnt = COUNT(1)
    FROM
    (
		SELECT P.IdPedido  AS IdPedido
        FROM MM_Pedido AS P
            JOIN dbo.MM_SolicitudPedido SP
                ON P.IdSolicitudPedido=SP.IdSolicitudPedido           
            JOIN MM_PeticionOferta AS PO
                ON P.IdPeticionOferta=PO.IdPeticionOferta
            JOIN S_Proveedor AS PV
                ON P.IdSubcontratista=PV.IdProveedor 
            JOIN TA_Operacion AS O
                ON  P.IdSolicitudPedido=O.IdDocumento 
            JOIN TA_Estatus AS E
                ON O.IdEstatusOperacion=E.IdEstatus
            JOIN MM_Pedidos AS PG
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 )
            JOIN Adinco.dbo.CO_Contrato AS C
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP
                ON PG.IdTipoPedido=TP.IdTipoPedido             
            LEFT JOIN dbo.DEA_Relacion_PR_PO RPO
                ON P.IdPedido=RPO.IdPedido 
            LEFT JOIN dbo.DEA_AdjuntoPO APO
                ON RPO.IdAdjuntoPO=APO.IdAdjuntoPO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
			  AND (CASE
                  WHEN CAST(PG.IdPedido AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN CAST(APO.ID_PO AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN CONCAT(ISNULL(PV.RazonSocial, ''),' ',ISNULL(PV.RegimenCapital, '')) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN UPPER(ISNULL(E.Nombre,'')) = UPPER(RTRIM(LTRIM(@Buscar))) THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1)             
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,                
                 PV.RazonSocial,
                 PV.RegimenCapital,                
                 E.Nombre,  
                 P.CreadoEl,
                 PG.IdPedido,
                 TP.TipoPedido,
                 APO.ID_PO,
                 C.NumeroContrato   
	  ) AS Total
	
	    IF @RecordCnt = 0
			SET @PageCount = 0;
		ELSE IF @RecordCnt % @PageSize = 0
			SET @PageCount = @RecordCnt / @PageSize;
		ELSE
			SET @PageCount = (@RecordCnt / @PageSize) + 1;

		--Registros paginados,filtrados y ordenados
		DECLARE @offset INT = (@PageSize * (@PageNumber - 1));

    
        SELECT P.IdPedido,
               P.IdSolicitudPedido,
               FORMAT(P.CreadoEl,'dd/MM/yyyy HH:mm') AS CreadoEl,
               CONCAT(ISNULL(PV.RazonSocial, ''),' ',ISNULL(PV.RegimenCapital, '')) AS Proveedor,               
               E.Nombre AS Estatus,    
               PG.IdPedido AS IdPedidoGeneral,
               TP.TipoPedido,                     
               APO.ID_PO,
               Contrato = C.NumeroContrato
        FROM MM_Pedido AS P
            JOIN dbo.MM_SolicitudPedido SP
                ON P.IdSolicitudPedido=SP.IdSolicitudPedido           
            JOIN MM_PeticionOferta AS PO
                ON P.IdPeticionOferta=PO.IdPeticionOferta
            JOIN S_Proveedor AS PV
                ON P.IdSubcontratista=PV.IdProveedor 
            JOIN TA_Operacion AS O
                ON  P.IdSolicitudPedido=O.IdDocumento 
            JOIN TA_Estatus AS E
                ON O.IdEstatusOperacion=E.IdEstatus
            JOIN MM_Pedidos AS PG
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = @IdProveedor
                   AND PG.IdTipoPedido IN ( 2, 4, 6 )
            JOIN Adinco.dbo.CO_Contrato AS C
                ON SP.IdContrato = C.IdContrato
            LEFT JOIN dbo.MM_TipoPedido AS TP
                ON PG.IdTipoPedido=TP.IdTipoPedido            
            LEFT JOIN dbo.DEA_Relacion_PR_PO RPO
                ON P.IdPedido=RPO.IdPedido 
            LEFT JOIN dbo.DEA_AdjuntoPO APO
                ON RPO.IdAdjuntoPO=APO.IdAdjuntoPO
        WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
              AND O.IdProveedor = @IdProveedor
              AND P.Version = O.NoVersion --> LA VERSIÓN DE PEDIDO DEBE SER LA MISMA QUE LA DE LA OPERACIÓN
              AND ISNULL(P.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO EL PEDIDO
			  AND (CASE
                  WHEN CAST(PG.IdPedido AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN CAST(APO.ID_PO AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN CONCAT(ISNULL(PV.RazonSocial, ''),' ',ISNULL(PV.RegimenCapital, '')) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1
			  OR CASE
                  WHEN UPPER(ISNULL(E.Nombre,'')) = UPPER(RTRIM(LTRIM(@Buscar))) THEN
                      1
                  WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                      1
                  ELSE
                      0
              END = 1)             
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,                
                 PV.RazonSocial,
                 PV.RegimenCapital,                
                 E.Nombre,  
                 P.CreadoEl,
                 PG.IdPedido,
                 TP.TipoPedido,
                 APO.ID_PO,
                 C.NumeroContrato   
	     ORDER BY CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'IdPedidoGeneral' THEN
                     PG.IdPedido
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'Proveedor' THEN
                     PV.RazonSocial
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'ID_PO' THEN
                     APO.ID_PO
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'Estatus' THEN
                     E.Nombre
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'CreadoEl' THEN
                     P.CreadoEl 
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'Contrato' THEN
                     C.NumeroContrato
             END ASC,			 
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'IdPedidoGeneral' THEN
                     PG.IdPedido
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'Proveedor' THEN
                     PV.RazonSocial
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'ID_PO' THEN
                     APO.ID_PO
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'Estatus' THEN
                     E.Nombre
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'CreadoEl' THEN
                     P.CreadoEl 
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'Contrato' THEN
                     C.NumeroContrato
             END DESC,			 
			 CASE
                 WHEN @OrderType = ''
                      AND @Order = '' THEN
                     P.CreadoEl 
			 END DESC
			OFFSET @offset ROWS FETCH NEXT @PageSize ROWS ONLY;


		SELECT @PageCount AS NumberPage,
        @RecordCnt AS AllRecords
  
END