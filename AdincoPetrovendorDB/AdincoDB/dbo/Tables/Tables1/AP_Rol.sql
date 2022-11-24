CREATE TABLE [dbo].[AP_Rol] (
    [IdRol]       INT            IDENTITY (1, 1) NOT NULL,
    [Rol]         NVARCHAR (MAX) NULL,
    [Descripción] NVARCHAR (MAX) NULL,
    [Activo]      BIT            NULL,
    [CreadoPor]   INT            NULL,
    CONSTRAINT [PK__AP_Rol__529C02D45B2BD080] PRIMARY KEY CLUSTERED ([IdRol] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
-- =============================================
-- Author:		Reyna
-- Create date: 06/02/2019
-- Description:	Inserta las opciones de menu en rol nuevo
-- =============================================
create TRIGGER [dbo].[Ap_InsertaOpcionesMenuRol]
ON [dbo].[ap_rol]
AFTER INSERT
AS
BEGIN
    
    INSERT INTO dbo.AP_MenuDPorRol
    (
        IdRol,
        IdMenu,
        Visible
    )
    SELECT R.IdRol,
           M.MenuId,
           0 AS Visible
     FROM INSERTED R
        CROSS JOIN dbo.AP_MenuD M
		GROUP BY R.IdRol,  M.MenuId
END;
