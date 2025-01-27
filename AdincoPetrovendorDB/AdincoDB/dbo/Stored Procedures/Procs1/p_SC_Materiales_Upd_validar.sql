IF OBJECT_ID('[dbo].[p_SC_Materiales_Upd_validar]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Materiales_Upd_validar]
GO

CREATE PROCEDURE [dbo].[p_SC_Materiales_Upd_validar]
@pIdSubcontrato INT,
@pIdSCMaterial INT,
@pCantidad DECIMAL(14,5),
@pError VARCHAR(250) OUT
AS
BEGIN
    BEGIN TRY
        SET @pError = ''
        DECLARE @cantidadOT DECIMAL(14,5) = 0  

        IF EXISTS (
            SELECT 1
            FROM OT_Solicitud (NOLOCK)
            WHERE IdSubcontrato = @pIdSubcontrato 
              AND IsActivo = 1 
              AND IDOTEstatus = 9
        )
        BEGIN
            SET @pError = 'Hay convenios pendientes para este contrato, no es posible actualizar esta partida. Es necesario ir a PROCURA a la sección de convenios para subcontratos'
            RETURN
        END

        SELECT @cantidadOT = dbo.fn_SC_GetCantidadUsada(@pIdSCMaterial)

        IF (@pCantidad < ISNULL(@cantidadOT, 0))
        BEGIN
            SET @pError = 'Las OT relacionadas a este servicio necesitan un mínimo de ' + CAST(ISNULL(@cantidadOT, 0) AS VARCHAR)
            RETURN
        END
    END TRY  
    BEGIN CATCH
        SET @pError = ERROR_MESSAGE()
    END CATCH
END
GO
