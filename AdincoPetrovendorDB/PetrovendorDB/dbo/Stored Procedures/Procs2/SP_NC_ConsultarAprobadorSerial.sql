-- =============================================
-- Author: Alexander Gomez
-- Create date: 20/09/2019
-- Description:	Consultar datos de la aprobacion de tarea
-- =============================================
CREATE  PROCEDURE [dbo].[SP_NC_ConsultarAprobadorSerial] 
    @IdUsuario INT,
    @IdOperacion INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT AD.IdTarea,--0
           AD.IdAprobador,--1
           U.Nombre,--2
           U.Correo,--3
           AD.IdOperacion,--4
           AD.NoSecuencia,--5
           PG.IdPedido,--6
           AP.IdAceptacionPedido,--7
           NC.IdAceptacionNotaCredito,--8
           P.IdSolicitudPedido--9
    FROM dbo.TA_Tarea AD
        LEFT JOIN dbo.TA_Operacion A
            ON A.IdOperacion = AD.IdOperacion
        LEFT JOIN dbo.S_Usuario U
            ON U.IdUsuario = AD.IdAprobador
        LEFT JOIN dbo.MM_AceptacionNotaCredito NC
            ON NC.IdAceptacionNotaCredito = A.IdDocumento
             
        LEFT JOIN dbo.MM_AceptacionPedido AP
            ON AP.IdAceptacionPedido = NC.IdAceptacionPedido
        LEFT JOIN dbo.MM_Pedido P
            ON P.IdPedido = AP.IdPedido
        LEFT JOIN dbo.MM_Pedidos PG
            ON PG.IdIdentificador = P.IdPedido
               AND PG.IdProveedorCliente = P.IdProveedorCompras
    WHERE AD.IdOperacion = @IdOperacion
          AND AD.IdAprobador = @IdUsuario
          AND AD.Activo = 1
          --AND AD.IdTarea = @IdTareaSiguiente
		  AND A.IdTipoOperacion = 17 -->Aprobación de nota de crédito

END;

