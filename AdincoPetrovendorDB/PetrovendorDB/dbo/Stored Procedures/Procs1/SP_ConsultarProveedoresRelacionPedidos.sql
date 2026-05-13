-- =============================================
-- Author:		DANIEL AC 
-- Create date: 23/01/2017
-- Description:	Filtro de proveedores que tiene al menos un pedido con el proveedor actual 
-- Author:		DANIEL AC 
-- Create date: 23/10/2017
-- Update: Se agrego consulta para proveedores de un comprobante extranjero
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarProveedoresRelacionPedidos]
    @IdProveedor INT,
    @TIPO NVARCHAR(300)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    IF @TIPO = 'PROVEEDORES'
    BEGIN
		 
		CREATE TABLE #PROVEEDORES(IdProveedor INT, Proveedor NVARCHAR(max), RFC NVARCHAR(max))
		INSERT INTO #PROVEEDORES	
		
		/*FILTRO PROVEEDORES QUE TIENE UN PEDIDO POR MERCADEO/AD DIRECTA ETC*/	
        SELECT PV.IdProveedor,
               ISNULL(PV.RazonSocial,'') + ' ' + ISNULL(PV.RegimenCapital,'') AS Proveedor,
               PV.RFC
        FROM S_Proveedor AS PV
            INNER JOIN dbo.MM_Pedido AS P
                ON P.IdSubcontratista = PV.IdProveedor                   
        WHERE P.IdProveedorCompras = @IdProveedor              
        GROUP BY PV.IdProveedor,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 PV.RFC
		UNION

		/*PROVEEDORES QUE TIENE FINCADA UNA ORDEN DE COMPRA*/
		SELECT P.IdProveedor, ISNULL(P.RazonSocial,'')+ ' '+ ISNULL(P.RegimenCapital,'') AS Proveedor, P.RFC
		FROM dbo.FI_Factura AS F
		left JOIN dbo.CO_Registro AS CO ON CO.IdFactura = F.IdFactura
		left JOIN dbo.TA_Operacion AS O ON O.IdDocumento = CO.IdFactura
		left JOIN dbo.S_Proveedor AS P ON F.Emisor =  P.RFC
		WHERE O.IdProveedor=@IdProveedor
		GROUP BY P.IdProveedor, P.RazonSocial, P.RFC ,P.RegimenCapital

		UNION 

		/*PROVEEDORES QUE TIENEN FINCADO ALGUN COMPROBANTE EXTRANJERA*/
		SELECT P.IdProveedor, ISNULL(P.RazonSocial,'')+ ' '+ ISNULL(P.RegimenCapital,'') AS Proveedor, P.RFC
		FROM dbo.FI_PedimentoComprobante AS PC		
		left JOIN dbo.TA_Operacion AS O ON O.IdDocumento = PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 --> Comprobante extranjero
		left JOIN dbo.S_Proveedor AS P ON PC.IdSubcontratistaExportador =  P.IdProveedor
		WHERE O.IdProveedor=@IdProveedor
		GROUP BY P.IdProveedor, P.RazonSocial, P.RFC ,P.RegimenCapital
				 

		SELECT IdProveedor, Proveedor, RFC 
		FROM #PROVEEDORES
		WHERE IdProveedor IS NOT NULL
		GROUP BY IdProveedor, Proveedor,RFC
		ORDER BY Proveedor

		
	END 

    IF @TIPO = 'USUARIO_COMPRADOR'
    BEGIN
        SELECT U.IdUsuario,
               U.Nombre
        FROM dbo.S_Usuario AS U
            INNER JOIN dbo.S_UsuarioProveedor AS UP
                ON UP.IdUsuario = U.IdUsuario
            INNER JOIN dbo.S_Proveedor AS PV
                ON PV.IdProveedor = UP.IdProveedor
            LEFT JOIN dbo.MM_Pedido AS P
                ON P.CreadoPor = U.IdUsuario
            LEFT JOIN dbo.CO_Registro AS R
                ON R.CreadoPor = U.IdUsuarioADINCO
			LEFT JOIN FI_PedimentoComprobante AS PC
				ON PC.CreadoPor=U.IdUsuario
        WHERE P.IdProveedorCompras = @IdProveedor
        GROUP BY U.IdUsuario,
                 U.Nombre
		ORDER BY U.Nombre
    END;

    IF @TIPO = 'USUARIO_REQUISITOR'
    BEGIN
        SELECT U.IdUsuario,
               U.Nombre
        FROM dbo.S_Usuario AS U
            INNER JOIN dbo.S_UsuarioProveedor AS UP
                ON UP.IdUsuario = U.IdUsuario
            INNER JOIN dbo.S_Proveedor AS PV
                ON PV.IdProveedor = UP.IdProveedor
            INNER JOIN dbo.MM_SolicitudPedido AS SP
                ON SP.IdUsuarioSolicitante = U.IdUsuario
            INNER JOIN dbo.MM_Pedido AS P
                ON P.IdProveedorCompras = PV.IdProveedor
                   AND SP.IdSolicitudPedido = P.IdSolicitudPedido
            LEFT JOIN dbo.CO_Registro AS R
                ON R.CreadoPor = U.IdUsuarioADINCO
			LEFT JOIN FI_PedimentoComprobante AS PC
				ON PC.CreadoPor=U.IdUsuario
        WHERE PV.IdProveedor = @IdProveedor
        GROUP BY U.IdUsuario,
                 U.Nombre
		ORDER BY U.Nombre
    END;

    IF @TIPO = 'TIPO_PEDIDO'
    BEGIN
        CREATE TABLE #TIPO
        (
            Tipo NVARCHAR(MAX)
        );
        INSERT INTO #TIPO
        (
            Tipo
        )
        VALUES
        (N'Compra directa');
        INSERT INTO #TIPO
        (
            Tipo
        )
        VALUES
        (N'Licitación');
        INSERT INTO #TIPO
        (
            Tipo
        )
        VALUES
        (N'Mercadeo');
		INSERT INTO #TIPO
        (
            Tipo
        )
        VALUES
        (N'Adjudicación directa');

		INSERT INTO #TIPO
        (
            Tipo
        )
        VALUES
        (N'Comprobante extranjero');
		
		SELECT * FROM #TIPO ORDER BY Tipo ASC

    END;

	 IF @TIPO = 'MONEDA'
    BEGIN
         	
		CREATE TABLE #MONEDA(IdMoneda INT, Moneda NVARCHAR(max))
		INSERT INTO #MONEDA		
        SELECT TM.IdMoneda,
		TM.TipoMonedaCorto
        FROM MM_Pedido AS P
            left JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda               
        WHERE P.IdProveedorCompras = @IdProveedor              
        GROUP BY TM.IdMoneda,
		TM.TipoMonedaCorto

		UNION

		SELECT TM.IdMoneda,
		TM.TipoMonedaCorto
		FROM dbo.FI_Factura AS F
		left JOIN dbo.CO_Registro AS CO ON CO.IdFactura = F.IdFactura
		LEFT JOIN dbo.TA_Operacion AS O ON O.IdDocumento = CO.IdFactura
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda= F.IdMoneda    
		WHERE O.IdProveedor=@IdProveedor
		GROUP BY TM.IdMoneda,
		TM.TipoMonedaCorto

		SELECT IdMoneda, Moneda FROM #MONEDA
		GROUP BY  IdMoneda, Moneda 
		ORDER BY Moneda
    END;


--- TT.IdEstatus = 2
END