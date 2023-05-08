CREATE PROCEDURE [dbo].[Mobile_Operadoras]
AS
    BEGIN
        SELECT IdContratista AS 'IdContratista', 
               RazonSocial AS 'RazonSocial', 
               Logo AS 'Logo'
        FROM dbo.CO_Contratista
		where ContratistaFicticio =0
        ORDER BY RazonSocial ASC;
    END;