-- =============================================
 
-- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue parametro IdProveedor, IdContrato  
-- =============================================
CREATE PROCEDURE [dbo].[sp_JACreacionJuntaAclaracion]
(
    @IdSolPed INT = 0,
    @FechaHora DATETIME,
    @Comentario NVARCHAR(MAX),
    @IdDomicilio INT,
    @IdUsuarioCreador INT,
	@IdProveedorCreador INT,
	@IdContratoCreador INT 
)
AS
BEGIN
    DECLARE @Topic INT

    INSERT INTO dbo.JA_TopicAclaraciones
    (
        IdDomicilio,
        FechaHoraJunta,
        Comentario,
        IdSolPed,
        CreadoPor,
        FechaCreado,
		IdProveedorCreador,
		IdContratoCreador
    )
    VALUES
    (   @IdDomicilio, -- IdDomicilio - int
        @FechaHora,   -- FechaHoraJunta - datetime
        @Comentario,  -- Comentario - nvarchar(max)
        @IdSolPed,    -- IdSolPed - int
        @IdUsuarioCreador,
        GETDATE(),
		@IdProveedorCreador,
		@IdContratoCreador
    )

    SELECT @Topic = @@IDENTITY

    --Mandar a notificacion
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolPed,          -- int
                                                @IdUsuario = @IdUsuarioCreador, -- int
                                                @TipoMensaje = 5,               -- int
                                                @IdPrimario = @Topic,           -- int
                                                @PetrovendorProcura = 2,         --Es petrovendor donde se insertando? --Adinco 2
												@IdProveedorCreador = @IdProveedorCreador,
												@IdContratoCreador =  @IdContratoCreador 

    --Se retorna el id topic para agregar a los participantes y los documentos
    SELECT @Topic

END