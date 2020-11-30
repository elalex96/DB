/****** Object:  StoredProcedure [dbo].[SP_InsertarBitacoraLogin]    Script Date: 27/12/2017 01:51:53 p. m. ******/

CREATE PROCEDURE [dbo].[SP_InsertarBitacoraLogin]
(
    @IpAddress NVARCHAR(50),
    @HostName NVARCHAR(MAX) = '',
    @SistemaOperativo NVARCHAR(100) = '',
    @Browser NVARCHAR(50) = '',
    @VersionBrowser NVARCHAR(50) = '',
    @IdUsuario INT = -1,
    @Aplicacion TINYINT = -1,
    @TipoUsuarioID INT = -1
)
AS
--BEGIN
    --INSERT INTO AP_BitacoraLogin
    --(
    --    IpAddress,
    --    HostName,
    --    SistemaOperativo,
    --    Browser,
    --    VersionBrowser,
    --    FechaIngreso,
    --    IdUsuario,
    --    Aplicacion,
    --    TipoUsuarioID
    --)
    --VALUES
    --(   @IpAddress,        -- IpAddress - nvarchar(50)
    --    @HostName,         -- HostName - nvarchar(max)
    --    @SistemaOperativo, -- SistemaOperativo - nvarchar(100)
    --    @Browser,          -- Browser - nvarchar(50)
    --    @VersionBrowser,   -- VersionBrowser - nvarchar(50)
    --    GETDATE(),         -- FechaIngreso - datetime
    --    @IdUsuario,        -- IdUsuario - int
    --    @Aplicacion,       -- Acceso - tinyint
    --    @TipoUsuarioID     -- TipoUsuarioID - int
    --)

--END

