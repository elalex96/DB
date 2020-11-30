-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180825
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE PR_ModificaCampo--'ff',12,3,10061
@id INT,
@nombre NVARCHAR(Max),
@bloque INT,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;
	IF (SELECT COUNT(id) FROM dbo.PR_Campo WHERE Nombre=RTRIM(LTRIM(@nombre)) AND Bloque=@bloque)=0
	BEGIN
    UPDATE  dbo.PR_Campo
    SET Clave=UPPER(RTRIM((LTRIM(@nombre)))),
        Nombre=UPPER(RTRIM((LTRIM(@nombre)))),
        Descripcion=UPPER((CONCAT('CAMPO ',REPLACE(RTRIM(LTRIM(@nombre)),'CAMPO','')))),
        Bloque=@bloque
   WHERE Id=@id
   
	END
END