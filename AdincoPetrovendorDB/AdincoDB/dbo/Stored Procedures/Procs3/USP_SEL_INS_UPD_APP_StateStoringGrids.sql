IF OBJECT_ID('[dbo].[USP_SEL_INS_UPD_APP_StateStoringGrids]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].USP_SEL_INS_UPD_APP_StateStoringGrids
GO

CREATE PROCEDURE USP_SEL_INS_UPD_APP_StateStoringGrids
    @UsuarioId   INT,
    @ContratoId  INT,
    @Grid        VARCHAR(100),
    @Body        VARCHAR(8000) = NULL,
    @Accion      VARCHAR(20),
	@FechaDel	 DATETIME = NULL,
	@FechaAl 	 DATETIME = NULL,
	@Pantalla	 VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Accion = 'InsertUpdate'
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM APP_StateStoringGrids (NOLOCK)
            WHERE UsuarioId = @UsuarioId 
              AND ContratoId = @ContratoId 
              AND Grid = @Grid
        )
        BEGIN
            UPDATE APP_StateStoringGrids
            SET Body = @Body,
				FechaDel = @FechaDel,
				FechaAl = @FechaAl,
                ModificadoEn = GETDATE()
            WHERE UsuarioId = @UsuarioId 
              AND ContratoId = @ContratoId 
              AND Grid = @Grid;
        END
        ELSE
        BEGIN
            INSERT INTO APP_StateStoringGrids (UsuarioId, ContratoId, Grid, Body, CreadoEn, Pantalla)
            VALUES (@UsuarioId, @ContratoId, @Grid, @Body, GETDATE(), @Pantalla);
        END
    END

    ELSE IF @Accion = 'Select'
    BEGIN
        SELECT TOP 1 Body, FechaDel, FechaAl
        FROM APP_StateStoringGrids (NOLOCK)
        WHERE UsuarioId = @UsuarioId
          AND ContratoId = @ContratoId
          AND Grid = @Grid;
    END
END
GO
	


