-- =============================================
 -- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue campos IdProveedorCreador,IdContratoCreador 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAInsertarEncabezadoConvocatoria]
(
    @IdUsuario INT,
    @Nombre NVARCHAR(MAX),
    @Paginas NVARCHAR(MAX),
    @PuntosBases NVARCHAR(MAX),
    @Pregunta NVARCHAR(MAX),
    @IdSolPed INT,
    @idOferta INT,
    @IdProveedorCreado INT,
	@IdContratoCreador INT, 
    @PetrovendorProcura INT = 2 --Petrovendor 0 - Procura 1 - Adinco 2
)
AS
BEGIN
    DECLARE @IdComentario INT,
            @IdProveedor INT,
            @OfertaMensaje INT,
            @NumeroDeProveedores INT,
            @Contador INT = 1,
            @max INT
    DECLARE @tablaAux TABLE
    (
        Fila INT,
        IdProveedor INT,
        OfertaMensaje INT
    )

    INSERT INTO dbo.JA_EncabezadoComentarios
    (
        Nombre,
        Paginas,
        PuntosBases,
        Pregunta,
        IdSolPed,
        CreadoPor,
        FechaCreado,
        IdProveedorCreador,
		IdContratoCreador
    )
    VALUES
    (   @Nombre,      -- Nombre - nvarchar(max)
        @Paginas,     -- Paginas - nvarchar(max)
        @PuntosBases, -- PuntosBases - nvarchar(max)
        @Pregunta,    -- Pregunta - nvarchar(max)
        @IdSolPed,    -- IdSolPed - int
        @IdUsuario,   -- CreadoPor - int
        GETDATE(),     -- FechaCreado - datetime
		@IdProveedorCreado,
		@IdContratoCreador
    )

    SELECT @IdComentario = @@IDENTITY

    --Enviar notificacion
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolPed,                    -- int
                                                @IdUsuario = @IdUsuario,                  -- int
                                                @TipoMensaje = 4,                         -- int
                                                @IdPrimario = @IdComentario,              -- int
                                                @PetrovendorProcura = @PetrovendorProcura, --Es petrovendor donde se insertando
												@IdProveedorCreador =@IdProveedorCreado,
												@IdContratoCreador = @IdContratoCreador



    --Retorno a la vista
    SELECT IdEncabezado,
           Nombre,
           Paginas,
           PuntosBases,
           Pregunta,
           IdSolPed,
           IdOferta
    FROM dbo.JA_EncabezadoComentarios
    WHERE IdEncabezado = @IdComentario
END
