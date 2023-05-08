CREATE PROCEDURE [dbo].BuscarDominioProcura
AS    
BEGIN
		SELECT URL FROM APP_URLRecursos where Tipo like 'DominioProcura'
END



