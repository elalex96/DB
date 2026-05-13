use Petrovendor
go
drop proc if exists MM_ConsultarLocalidades
go
-- =============================================
-- Author:		Daniel AC
-- Create date: <04-09-2023>
-- Description:	Consultar las localidades del proveedor/operadora actual 
-- =============================================
-- Author:		Luis David
-- Create date: <11-09-2023>
-- Description:	Se agrega trim a izquierda y derecha del nombre de la localidad
-- =============================================
CREATE PROCEDURE [dbo].[MM_ConsultarLocalidades] 
@IdProveedor INT ,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
					
	SELECT L.Id AS IdLocalidad, LTRIM(RTRIM(ISNULL(L.Nombre,''))) AS Nombre
	FROM MM_Localidades L (NOLOCK)	
	WHERE L.IdProveedor = @IdProveedor
	AND L.Activo = 1 --> QUE ESTE ACTIVA	
	ORDER BY Nombre ASC

END
