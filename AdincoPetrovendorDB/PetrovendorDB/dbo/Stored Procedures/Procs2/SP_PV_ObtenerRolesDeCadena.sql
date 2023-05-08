-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ObtenerRolesDeCadena]
@Roles NVARCHAR(MAX)
AS
DECLARE
  @strCadena VARCHAR(255),
  @newStrCadena VARCHAR(MAX),
  @strRol int

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #RolesTemp -- TABLA TEMPORAL QUE ALMACENA LOS NUEVOS ROLES
	(
	IdRow INT IDENTITY(1,1) NOT NULL,
	IdRolTemp INT
	)

	SET @strCadena = @Roles
	SET @newStrCadena = (@strCadena + ',')

	DECLARE @begin INT = 0, @count INT = 0, @max INT
	
	SELECT @max = LEN(@newStrCadena) - LEN(REPLACE(@newStrCadena,',',''))

	WHILE @count < @max
    BEGIN
	SET @strRol =( CAST( SUBSTRING(@newStrCadena,@begin,CHARINDEX(',',@newStrCadena,@begin + 1)- @begin) as INT)) -- OBTENER LOS ROLES

	SET @begin = (CHARINDEX(',',@newStrCadena,@begin+1) + 1)
	SET @count = @count + 1


	INSERT INTO #RolesTemp -- INSERTAR EL ROL DE LA CADENA
	(
	IdRolTemp
	)
	VALUES(
	@strRol
	)
	END 

	SELECT * FROM #RolesTemp

END

