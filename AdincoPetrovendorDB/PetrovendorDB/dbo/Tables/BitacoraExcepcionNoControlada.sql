CREATE TABLE [dbo].[BitacoraExcepcionNoControlada] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [StackTrace]     NVARCHAR (MAX) NULL,
    [InnerException] NVARCHAR (MAX) NULL,
    [Mensaje]        NVARCHAR (MAX) NULL,
    [Pagina]         NVARCHAR (MAX) NULL,
    [Aplicacion]     INT            NULL,
    [Fecha]          DATETIME       NULL
);

