CREATE VIEW [dbo].[BI_Jaguar_Materiales]
AS
     SELECT IdMaterial AS IdAdinco, 
            CONCAT('No. Material: ', IdMaterial, ' | Descripción: ', DescripcionCorta) AS Descripcion,
			Marca AS Marca,
                Modelo AS Modelo,
                NumeroParte AS NumeroParte
     FROM dbo.MM_Material
     WHERE IdProveedor IN(606, 690, 1835);