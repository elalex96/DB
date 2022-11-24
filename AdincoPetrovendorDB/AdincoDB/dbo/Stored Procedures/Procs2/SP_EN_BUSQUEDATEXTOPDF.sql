
CREATE PROCEDURE [dbo].[SP_EN_BUSQUEDATEXTOPDF]
@TextoDocumento varchar(max)
AS
BEGIN 
SELECT IdLineamientoDocumento, NombreDocumento
from EN_LineamientoDocumento
where TextoDocumento LIKE '%'+@TextoDocumento+'%'
END

