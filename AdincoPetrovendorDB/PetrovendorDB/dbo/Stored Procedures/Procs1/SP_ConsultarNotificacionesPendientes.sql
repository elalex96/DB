-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <18/12/19>
-- Description:	<Consulta la lista de notificaciones pendientes>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarNotificacionesPendientes] --420,2205
@IdProveedor INT,
@IdUsuario INT,
@IdContrato INT = NULL,
@FechaRegistro DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @Notificaciones TABLE
    (
        IdOperacion INT,
        IdTabla INT,
        Cabecera NVARCHAR(MAX),
        Descripcion NVARCHAR(MAX),
        Proveedor NVARCHAR(500),
        [Date] NVARCHAR(100),
        FechaRegistro DATETIME,
        QuerystringParams NVARCHAR(MAX),
        IdNotificacionTipo INT,
        ProveedorPetrovendor NVARCHAR(300)
    )

    DECLARE @Date TABLE
    (
        IdOperacion INT,
        [Year] NVARCHAR(100),
        [Month] NVARCHAR(100),
        [day] NVARCHAR(100),
        [Hour] NVARCHAR(100),
        [Minute] NVARCHAR(100),
        [second] NVARCHAR(100)
    )


    
    SELECT N.IdOperacion,
           N.IdTabla,
           N.Cabecera,
           CASE
               WHEN LEN(N.Descripcion) >= 50 THEN
                   SUBSTRING(N.Descripcion, 0, 50) + '...'
               ELSE
                   N.Descripcion
           END AS Descripcion,
           N.Proveedor,
           N.Date,
           N.FechaRegistro,
           N.QuerystringParams,
           N.IdNotificacionTipo,
           N.ProveedorPetrovendor,
           '' AS  Aprobador
    FROM @Notificaciones N
       
    ORDER BY FechaRegistro DESC

END
