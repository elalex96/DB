
-- =============================================  
-- Author:      Daniel Cruz  
-- Create date: 04-01-2022  
-- Description: Se clasifican las aprobaciones seriales de las paralelos
-- =============================================              
-- =============================================  
-- Author:      josue Gonzalez  
-- Create date: 15-08-2018  
-- Description: Se concatena el numero de pedido a la columna requisicion.    
-- =============================================  
CREATE PROCEDURE [dbo].[SP_TA_ConsultarTareasdeAprobacion]  
    -- Add the parameters for the stored procedure here  
    @IdUsuario INT,  
    @IdProveedor INT,  
    @IdTipoOperacion INT  
AS  
BEGIN  

    DECLARE @FlujoSerial TABLE  
    (  
        IdOperacion INT,  
        NoSecuencia INT  
    );  
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);  

    INSERT INTO @FlujoSerial  
    (  
        IdOperacion,  
        NoSecuencia  
    )  
    SELECT O.IdOperacion,  
           t.NoSecuencia  
    FROM dbo.TA_Operacion O  
		JOIN dbo.TA_FlujoTarea FT (NOLOCK) 
			ON O.IdFlujoTarea=FT.IdFlujoTarea	 
		AND FT.IdTipoFlujo= 1 --> FLUJO DE APROBACIÓN SERIAL 
        LEFT JOIN dbo.MM_Pedido p  
            ON  O.IdDocumento   = p.IdSolicitudPedido 
               AND O.NoVersion   = p.Version 
        INNER JOIN dbo.TA_Tarea t  
            ON O.IdOperacion  = t.IdOperacion 
    WHERE O.IdTipoOperacion = 9  
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO  
          AND t.IdAprobador = @IdUsuario  
          AND t.NoSecuencia > 1;  

    INSERT INTO @OperacionNoAprobadas  
    (  
        IdOperacion  
    )  
    SELECT O.IdOperacion  
    FROM dbo.TA_Operacion O  
        INNER JOIN @FlujoSerial f  
            ON O.IdOperacion  = f.IdOperacion 
        INNER JOIN dbo.TA_Tarea T  
            ON O.IdOperacion  = T.IdOperacion 
               AND T.NoSecuencia = (f.NoSecuencia - 1)  
    WHERE O.IdTipoOperacion = 9 
          AND T.IdEstatus <> 2; 
		   
    SELECT O.IdOperacion,  
           O.IdDocumento,  
           O.FechaRegistro,  
            CONCAT('Pedido: ', P2.IdPedido,' - Requisicion: ', O.IdDocumento, ' - Descripción: ', O.Descripcion) AS Descripcion,  
           E.Nombre,  
           P.Version,  
           GETDATE() AS FechaVigencia,  
           prov.RazonSocial,  
           P.Version,  
           P.IdSubcontratista,  
           sp.MotivoUrgencia  
    FROM TA_Operacion AS O  
        INNER JOIN MM_Pedido AS P 
			ON O.IdDocumento  = P.IdSolicitudPedido 
        INNER JOIN    MM_Pedidos P2 
			ON P.IdPedido = P2.IdIdentificador 
			AND P.IdProveedorCompras = P2.IdProveedorCliente
			AND P2.IdTipoPedido IN ( 2, 4, 6 ) 
        LEFT JOIN dbo.MM_SolicitudPedido SP 
			ON P.IdSolicitudPedido  =SP.IdSolicitudPedido 
        LEFT JOIN TA_Estatus AS E 
			ON O.IdEstatusOperacion  = E.IdEstatus 
        LEFT JOIN TA_Tarea AS T 
			ON O.IdOperacion = T.IdOperacion   
        LEFT JOIN dbo.S_Usuario U 
			ON T.IdAprobador  = U.IdUsuario   
        LEFT JOIN dbo.S_UsuarioProveedor UP 
			ON U.IdUsuario   = UP.IdUsuario
            AND SP.IdContrato = UP.IdContrato  
            AND O.IdProveedor   = UP.IdProveedor
        LEFT JOIN dbo.S_Proveedor prov 
			ON  P.IdSubcontratista = prov.IdProveedor 
    WHERE T.IdAprobador = @IdUsuario  
          AND O.IdProveedor = @IdProveedor  
          AND O.IdTipoOperacion = @IdTipoOperacion  
          AND P.Version = O.NoVersion  
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO  
          AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->Pedido no eliminado  
          AND O.IdOperacion NOT IN (  
                                       SELECT IdOperacion FROM @OperacionNoAprobadas  
                                    ) AND T.idestatus = 1 -->No mostrar si ya se aprobo MG   
    GROUP BY O.IdOperacion,  
             O.IdDocumento,  
             O.FechaRegistro,  
             O.Descripcion,  
             E.Nombre,  
             O.IdTipoOperacion,  
             P.Version,  
             prov.RazonSocial,  
             P.IdSubcontratista,  
             sp.MotivoUrgencia,  
            P2.IdPedido  
    ORDER BY P2.IdPedido DESC;  

END;