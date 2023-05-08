-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180825
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE PR_InsertaCampo--'ff',12,3,10061
--@clave NVARCHAR(Max),
@nombre NVARCHAR(Max),
@bloque INT,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;
	IF (SELECT COUNT(id) FROM dbo.PR_Campo WHERE Nombre=RTRIM(LTRIM(@nombre)) AND Bloque=@bloque)=0
	BEGIN
    INSERT INTO dbo.PR_Campo
    (
        Clave,
        Nombre,
        Descripcion,
        Estatus,
        Bloque
    )
    VALUES
    (  
	   UPPER(@nombre),  -- Clave - varchar(20)
       UPPER(@nombre),  -- Nombre - varchar(200)
       UPPER((CONCAT('CAMPO ',REPLACE(@nombre,'CAMPO','')))), -- Descripcion - nvarchar(2000)
        1,   -- Estatus - tinyint
         @bloque   -- Bloque - int
        )
	END
END