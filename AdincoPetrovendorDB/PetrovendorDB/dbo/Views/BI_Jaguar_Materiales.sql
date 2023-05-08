CREATE VIEW [dbo].[BI_Jaguar_Materiales]
AS
     --VISTA PARA CONSULTAR MATERIALES DE LOS PROVEEDORES DE JAGUAR 
     SELECT M.IdMaterial AS IdAdinco, 
            CONCAT('No. Material: ', M.IdMaterial, ' | Descripción: ', M.DescripcionCorta) AS Descripcion,
			M.Marca AS Marca,
            M.Modelo AS Modelo,
            M.NumeroParte AS NumeroParte,
			MT.Descripcion AS Categoria,
			M.DescripcionLarga,
			U.Unidad AS UnidadPredeterminada,
			P.RazonSocial AS Empresa
     FROM dbo.MM_Material M
	 JOIN S_Proveedor P 
	 ON M.IdProveedor=P.IdProveedor
	 AND  M.IdProveedor IN(606, 690, 1835) --> PROVEEDORES ESTATICOS 
	 JOIN MM_TipoMaterialProcura MT
	 ON M.IdTipoCatalogoMaestro = MT.IdTipoMaterialProcura
	 JOIN PV_MM_MaterialUnidad U 
	 ON M.IdUnidad=U.IdUnidad	
      

