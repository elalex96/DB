-- =============================================
-- Author: Daniel AC
-- Update: 11-07-2022
-- Description:Lista de SAS filtradas por pedido
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultaSASxPedidoId] 
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,    
    @IdUsuario INT,
	@IdContrato INT,
	@IdPedido INT,
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
	
	DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')
	SET @Buscar =LTRIM(RTRIM(@Buscar))
	
	--VALIDACIÓN DE PRECONDICIONES
    SET @PageCount = 0;
    IF @PageSize < 1
       OR @PageNumber < 1
    BEGIN
        SET @PageSize = 10;
        SET @PageNumber = 1;
    END;

	SELECT @RecordCnt = COUNT(1)
    FROM
    (
       	SELECT	   COUNT(1) as Id
		FROM		MM_SolicitudAceptacionPedido			SAP (NOLOCK)
		JOIN		TA_Operacion							O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido			=	O.IdDocumento
		AND			SAP.Activo								=	1
		AND			O.IdTipoOperacion						=	@TipoOperacionId -->CTE 20
		JOIN		TA_Estatus								E (NOLOCK)
		ON			O.IdEstatusOperacion					=	E.IdEstatus
		JOIN		MM_Pedido								P (NOLOCK)
		ON			SAP.IdPedido							=	P.IdPedido
		AND			P.IdPedido								=   @IdPedido
		AND			P.IdProveedorCompras					=	@IdProveedor		
		JOIN		MM_Pedidos								PG (NOLOCK)
		ON			P.IdPedido								=	PG.IdIdentificador 
		AND			P.IdProveedorCompras					=	PG.IdProveedorCliente						
		AND			PG.IdTipoPedido							in	(2,4,6) --> CTES		
		LEFT JOIN	S_Usuario								UE (NOLOCK)
		ON			SAP.CreadorPor							=	UE.IdUsuario
		LEFT JOIN	MM_SolicitudPedido						SP (NOLOCK)
		ON			P.IdSolicitudPedido						=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario								US (NOLOCK)
		ON			SP.Solicitante							=	US.IdUsuario			
		LEFT JOIN	DEA_Relacion_PR_PO AS RPO	(NOLOCK)
		ON			P.IdPedido								= RPO.IdPedido
		WHERE		P.IdProveedorCompras					=	@IdProveedor 
		AND (
		CASE
            WHEN CAST(SAP.IdSolicitudAceptacionPedido AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1
		OR CASE
            WHEN CAST(E.Nombre AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1
		OR CASE
            WHEN CAST(US.Nombre AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1)
		GROUP BY    P.IdPedido,     
					 P.IdSolicitudPedido,	
					 PG.IdPedido,					
					 E.Nombre,
					 SAP.IdSolicitudAceptacionPedido,	
					 SAP.CreadoEl,
					 UE.Nombre,
					 US.Nombre,
					 SAP.IdAceptacionPedido,
					 RPO.PO
		) AS Total

		 IF @RecordCnt = 0
			SET @PageCount = 0;
		ELSE IF @RecordCnt % @PageSize = 0
			SET @PageCount = @RecordCnt / @PageSize;
		ELSE
			SET @PageCount = (@RecordCnt / @PageSize) + 1;

		--Registros paginados,filtrados y ordenados
		DECLARE @offset INT = (@PageSize * (@PageNumber - 1));


		SELECT	    SAP.IdSolicitudAceptacionPedido,					
					P.IdPedido,    
					P.IdSolicitudPedido,    
					IdPedidoGeneral							=	PG.IdPedido,					
					EstatusAprobacion						=	E.Nombre,					
					SolitudCreadaEl							=	FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy HH:mm'),
					SolitanteRequisicion					=	US.Nombre,
					SAP.IdAceptacionPedido,
					ISNULL(RPO.PO,'Sin PO relacionada') AS PO
		FROM		MM_SolicitudAceptacionPedido			SAP (NOLOCK)
		JOIN		TA_Operacion							O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido			=	O.IdDocumento
		AND			SAP.Activo								=	1
		AND			O.IdTipoOperacion						=	@TipoOperacionId -->CTE 20
		JOIN		TA_Estatus								E (NOLOCK)
		ON			O.IdEstatusOperacion					=	E.IdEstatus
		JOIN		MM_Pedido								P (NOLOCK)
		ON			SAP.IdPedido							=	P.IdPedido
		AND			P.IdPedido								=   @IdPedido
		AND			P.IdProveedorCompras					=	@IdProveedor		
		JOIN		MM_Pedidos								PG (NOLOCK)
		ON			P.IdPedido								=	PG.IdIdentificador 
		AND			P.IdProveedorCompras					=	PG.IdProveedorCliente						
		AND			PG.IdTipoPedido							in	(2,4,6) --> CTES		
		LEFT JOIN	S_Usuario								UE (NOLOCK)
		ON			SAP.CreadorPor							=	UE.IdUsuario
		LEFT JOIN	MM_SolicitudPedido						SP (NOLOCK)
		ON			P.IdSolicitudPedido						=	SP.IdSolicitudPedido
		LEFT JOIN	S_Usuario								US (NOLOCK)
		ON			SP.Solicitante							=	US.IdUsuario			
		LEFT JOIN	DEA_Relacion_PR_PO AS RPO	(NOLOCK)
		ON			P.IdPedido								= RPO.IdPedido
		WHERE		P.IdProveedorCompras					=	@IdProveedor 	
		AND (
		CASE
            WHEN CAST(SAP.IdSolicitudAceptacionPedido AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1
		OR CASE
            WHEN CAST(E.Nombre AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1
		OR CASE
            WHEN CAST(US.Nombre AS NVARCHAR(MAX)) LIKE '%' + RTRIM(LTRIM(@Buscar)) + '%' THEN
                1
            WHEN RTRIM(LTRIM(@Buscar)) = '' THEN
                1
            ELSE
                0
        END = 1)
		GROUP BY    P.IdPedido,     
					 P.IdSolicitudPedido,	
					 PG.IdPedido,					
					 E.Nombre,
					 SAP.IdSolicitudAceptacionPedido,	
					 SAP.CreadoEl,
					 UE.Nombre,
					 US.Nombre,
					 SAP.IdAceptacionPedido,
					 RPO.PO
		ORDER BY CASE
            WHEN @OrderType = 'asc'
                      AND @Order = 'IdSolicitudAceptacionPedido' THEN
                     SAP.IdSolicitudAceptacionPedido
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'SolitanteRequisicion' THEN
                     US.Nombre
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'EstatusAprobacion' THEN
                     E.Nombre
             END ASC,
			 CASE
                 WHEN @OrderType = 'asc'
                      AND @Order = 'SolitudCreadaEl' THEN
                    SAP.CreadoEl
             END ASC,
			 CASE
            WHEN @OrderType = 'desc'
                      AND @Order = 'IdSolicitudAceptacionPedido' THEN
                     SAP.IdSolicitudAceptacionPedido
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'SolitanteRequisicion' THEN
                     US.Nombre
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'EstatusAprobacion' THEN
                     E.Nombre
             END DESC,
			 CASE
                 WHEN @OrderType = 'desc'
                      AND @Order = 'SolitudCreadaEl' THEN
                    SAP.CreadoEl
             END DESC,
			 CASE
                 WHEN @OrderType = ''
                      AND @Order = '' THEN
                      SAP.IdSolicitudAceptacionPedido
			 END DESC
		OFFSET @offset ROWS FETCH NEXT @PageSize ROWS ONLY;


		SELECT @PageCount AS NumberPage,
        @RecordCnt AS AllRecords
  
END