CREATE PROCEDURE [dbo].[sp_JAAgregarDomicilio]
(
    @IdProveedor INT,
    @Domicilio NVARCHAR(MAX),
	@IdUsuarioCreador INT
)
AS
BEGIN
    INSERT INTO dbo.JA_LugarJunta
    (
        Domicilio,
        IdProveedor,
		CreadoPor,
		FechaCreado
    )
    VALUES
    (   @Domicilio, -- Domicilio - nvarchar(max)
        @IdProveedor,
		@IdUsuarioCreador,
		GETDATE()
    )

    --retornar el id del domicilio agregado para poder asignarlo al combo
    SELECT @@IDENTITY
END


