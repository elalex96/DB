-- =============================================
-- Author:		<Pedro ,Acuña >
-- Modified date: <12/Enero/2018>
-- Description:	<Insertar en Bitacora los errores no controlados >
-- =============================================
CREATE PROCEDURE SP_BitacoraExcepcionNoControlada
(
    @StackTrace NVARCHAR(MAX),
    @InnerException NVARCHAR(MAX),
    @Mensaje NVARCHAR(MAX),
    @Pagina NVARCHAR(MAX),
    @Aplicacion INT
)
AS
BEGIN
    INSERT INTO dbo.BitacoraExcepcionNoControlada
    (
        StackTrace,
        InnerException,
        Mensaje,
        Pagina,
        Aplicacion,
        FECHA
    )
    VALUES
    (   @StackTrace,     -- StackTrace - nvarchar(max)
        @InnerException, -- InnerException - nvarchar(max)
        @Mensaje,        -- Mensaje - nvarchar(max)
        @Pagina,         -- Pagina - nvarchar(max)
        @Aplicacion,     -- Aplicacion - int
        GETDATE()        -- FECHA - datetime
    )
END