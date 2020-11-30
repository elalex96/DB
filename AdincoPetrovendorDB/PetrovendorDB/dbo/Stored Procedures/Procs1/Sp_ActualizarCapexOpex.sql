-- =============================================
-- Author:		Pedro Acuña
-- Create date: 15/11/2019
-- Description:	Actualiza el campo de Capex y Opex
-- =============================================
CREATE PROCEDURE [dbo].Sp_ActualizarCapexOpex
    @CapexOpex INT,
    @IdSolicitudPedido INT,
    @IdUsuario INT
AS
BEGIN
    DECLARE @IdTipoGastoAnterior INT
    SELECT @IdTipoGastoAnterior = IdTipoGasto
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    IF (
           (
               ISNULL(@CapexOpex, 0) = 1
               OR ISNULL(@CapexOpex, 0) = 2
           )
           AND ISNULL(@IdSolicitudPedido, 0) <> 0
       )
    BEGIN
        UPDATE dbo.MM_SolicitudPedido
        SET IdTipoGasto = @CapexOpex
        WHERE IdSolicitudPedido = @IdSolicitudPedido

        INSERT INTO dbo.HistoricoCapexOpex
        (
            IdSolicitudPedido,
            IdUsuarioModifico,
            CapexOpex,
            FechaModificado
        )
        SELECT @IdSolicitudPedido,
               @IdUsuario,
               @IdTipoGastoAnterior,
               GETDATE()
    END
    ELSE
    BEGIN
        DECLARE @TextoRetorno NVARCHAR(MAX)
            = CONCAT(
                        'Se intenta actualizar un campo Capex u Opex que no existe o el numero de solicitud de pedido es 0. Capex u Opex: ',
                        LTRIM(@CapexOpex),
                        ' IdSolicitudPedido: ',
                        @IdSolicitudPedido
                    )

        RAISERROR(@TextoRetorno, 16, 1)
    END



    SELECT 1 -- retorno a la vista
END

