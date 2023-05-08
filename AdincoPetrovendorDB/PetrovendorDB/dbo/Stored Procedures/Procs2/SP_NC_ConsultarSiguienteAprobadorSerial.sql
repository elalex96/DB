-- =============================================
-- Author: Daniel AC
-- Create date: 02/0/8/2019
-- Description:	Consultar y actualizar estatus de la tarea de tipo serial
-- =============================================
CREATE PROCEDURE [dbo].[SP_NC_ConsultarSiguienteAprobadorSerial] ---420,2205,11732,21968
    @IdProveedor INT,
    @IdUsuario INT,
    @IdOperacion INT,
    @IdTarea INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @NoSecuenciaActual INT;
    DECLARE @IdTareaSiguiente INT;

    SELECT @NoSecuenciaActual = NoSecuencia
    FROM dbo.TA_Tarea
    WHERE IdOperacion = @IdOperacion
          AND IdTarea = @IdTarea;


    SET @NoSecuenciaActual = (ISNULL(@NoSecuenciaActual, 0) + 1);

    SELECT @IdTareaSiguiente = AD.IdTarea
    FROM dbo.TA_Tarea AD
        LEFT JOIN dbo.TA_Operacion A
            ON A.IdOperacion = AD.IdOperacion
        LEFT JOIN dbo.S_Usuario U
            ON U.IdUsuario = AD.IdAprobador
    WHERE AD.IdOperacion = @IdOperacion
          AND AD.NoSecuencia = @NoSecuenciaActual
          AND AD.Activo = 1;

    UPDATE dbo.TA_Tarea
    SET IdEstatus = 1, --> CAMBIAR DE 9  A 1 SIN INICIAR APROBACIÓN A EN APROBACIÓN -->TA_Estatus 
        FechaActivacionSerial = GETDATE()
    WHERE IdTarea = @IdTareaSiguiente
          AND IdOperacion = @IdOperacion;

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
          AND AD.NoSecuencia = @NoSecuenciaActual
          AND AD.Activo = 1
          AND AD.IdTarea = @IdTareaSiguiente
		  AND A.IdTipoOperacion = 17 -->Aprobación de nota de crédito

END;

