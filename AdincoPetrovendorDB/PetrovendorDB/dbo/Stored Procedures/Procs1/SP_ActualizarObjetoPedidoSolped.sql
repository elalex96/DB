-- =============================================
-- Creacion: Pedro Acuña
-- Update date: 07/10/2019
-- Description:	Agregue validación para que solo se oculten las aprobaciones de tipo serial donde el aprobador anterior no ha aprobado su tarea 
-- =============================================
CREATE PROCEDURE SP_ActualizarObjetoPedidoSolped
    @IdSolicitudPedido INT,
    @Descripcion NVARCHAR(MAX),
    @IdUsuario INT
AS
BEGIN
    DECLARE @DescripcionAnterior NVARCHAR(MAX)

    SELECT @DescripcionAnterior = MotivoUrgencia
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    IF (ISNULL(@IdSolicitudPedido, 0) <> 0)
    BEGIN
        UPDATE dbo.MM_SolicitudPedido
        SET MotivoUrgencia = @Descripcion
        WHERE IdSolicitudPedido = @IdSolicitudPedido
    END

    SELECT CASE
               WHEN @@ROWCOUNT > 0 THEN
                   'True'
               WHEN @@ROWCOUNT = 0 THEN
                   'False'
           END AS Retorno,
           IdSolicitudPedido,
           MotivoUrgencia
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    INSERT INTO dbo.HistorialObjetoDelPedido
    (
        IdSolicitudPedido,
        IdUsuarioModifico,
        MotivoAnterior,
        FechaModificado
    )
    SELECT @IdSolicitudPedido,
           @IdUsuario,
           @DescripcionAnterior,
           GETDATE()

END






